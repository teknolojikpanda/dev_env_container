#!/bin/bash

set -euo pipefail

PROG_DESC='Development Environment Build Script - TeknolojikPanda'
ARCH_TYPES_OUT=""

script_name=$(basename $0)
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
run_cmd_return=0

msg() {
    local mesg=$1; shift
    printf ">>> $(basename ${BASH_SOURCE[1]})#${BASH_LINENO[0]} %s\n\n" "$mesg"
    if [[ $# -gt 0 ]]; then
        printf '%s ' "${@}"
        printf '\n\n'
    fi
}

run_cmd() {
    run_cmd_return=0
    run_cmd_return=0
    # $@: The command and args to run
    printf "%s\n\n" "$(basename ${BASH_SOURCE[${SOURCE_LINE_OVERRIDE:-1}]})#${BASH_LINENO[${BASH_LINE_OVERRIDE:-0}]} Running command:"
    printf "%s " "${@}"
    printf "\n\n"
    printf "Output: \n\n"
    echo -e "$@" | source /dev/stdin
    run_cmd_return=$?
    echo
    printf "Command returned: %s\n\n" "${run_cmd_return}"
    return $run_cmd_return
}

for arch_type_in in `ls ${script_dir}/arch_types`; do
	arch_types+=("${arch_type_in}" "" "off")
done
while [ "${ARCH_TYPES_OUT}" == "" ]; do
	ARCH_TYPES_OUT=$(dialog --stdout --backtitle "${PROG_DESC}"  \
							--title "Architecture Type Selection" \
							--checklist "Please select arch type for build image." 10 70 4 "${arch_types[@]}")
	if [ -z ${ARCH_TYPES_OUT} ]; then
		dialog  --backtitle "${PROG_DESC}" \
				--msgbox "No arch type selected! Please select one." 6 46
	fi
done
echo

for ARCH_TYPE in ${ARCH_TYPES_OUT}; do
	IMAGE_VERSION=$(cat ${script_dir}/arch_types/${ARCH_TYPE}/Dockerfile | grep version | cut -d\" -f2)
	msg "START - Building Docker Image - ${ARCH_TYPE}"
	run_cmd docker build -f ${script_dir}/arch_types/${ARCH_TYPE}/Dockerfile -t dev_env_${ARCH_TYPE} .
	msg "END - Building Docker Image - ${ARCH_TYPE}"

	if dialog --stdout --backtitle "${PROG_DESC}"  \
	 	   	  --title "Tag/Push" \
	       	  --yesno "IMG_VER: ${IMAGE_VERSION}\nARCH_TYPE: ${ARCH_TYPE}\n-------\nDo you want to tag and push builded image to Docker HUB?" 10 51; then
	    echo
		msg "START - Tagging Docker Image - ${ARCH_TYPE}"
		run_cmd docker image tag dev_env_${ARCH_TYPE} teknolojikpanda/dev_env_${ARCH_TYPE}:${IMAGE_VERSION}
		run_cmd docker image tag teknolojikpanda/dev_env_${ARCH_TYPE}:${IMAGE_VERSION} teknolojikpanda/dev_env_${ARCH_TYPE}:latest
		msg "END - Tagging Docker Image - ${ARCH_TYPE}"

		msg "START - Pushing Docker Image to HUB - ${ARCH_TYPE}"
		run_cmd docker push teknolojikpanda/dev_env_${ARCH_TYPE}:${IMAGE_VERSION}
		run_cmd docker push teknolojikpanda/dev_env_${ARCH_TYPE}:latest
		msg "END - Pushing Docker Image to HUB - ${ARCH_TYPE}"
	else
		dialog  --backtitle "${PROG_DESC}" \
				--msgbox "Skipping Tagging and Pushing Docker Image - ${ARCH_TYPE}" 6 55
	fi
done