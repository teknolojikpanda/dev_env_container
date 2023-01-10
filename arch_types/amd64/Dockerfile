# syntax=docker/dockerfile:1
FROM --platform=linux/amd64 rockylinux:8.6
LABEL version="1.1"
LABEL maintainer="TeknolojikPanda"
LABEL usage_cmd="docker run -d -it --privileged --platform linux/amd64 -p 1122:22 -p 3389:3389 -v ~/.config/pulse:/root/.config/pulse:ro --name <container_name> -h <hostname> teknolojikpanda/dev_env_amd64"
RUN yum upgrade -y && yum groupinstall 'Server with GUI' 'Development Tools' --allowerasing -y && yum install epel-release -y
RUN echo -e "<add_your_password>\n<add_your_password>" | passwd root
CMD /sbin/init
RUN systemctl unmask systemd-logind
RUN yum install -y xrdp xorgxrdp && systemctl enable xrdp
RUN echo "X-GNOME-Autostart-enabled=false" >> /etc/xdg/autostart/gnome-initial-setup-first-login.desktop
ENV PULSE_SERVER=host.docker.internal
COPY docker_sound.sh /etc/profile.d
