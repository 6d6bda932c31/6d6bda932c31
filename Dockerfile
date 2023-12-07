#FROM ubuntu:jammy
FROM ubuntu:lunar

# update and install software
RUN export DEBIAN_FRONTEND=noninteractive  \
	&& apt-get update -qy \
	&& apt-get full-upgrade -qy \
	&& apt-get dist-upgrade -qy \
	&& apt-get install -qy \
        sudo wget curl unzip tar git xz-utils apt-utils openssh-server build-essential software-properties-common \
        openjdk-17-jdk openjdk-17-jre nano tigervnc-standalone-server python3-pip novnc net-tools  \
        x11vnc dbus-x11 lsb-release ca-certificates apt-transport-https cinnamon* xrdp

# Fix en_US.UTF-8
RUN apt-get install locales -qy \
	&& echo "LC_ALL=en_US.UTF-8" >> /etc/environment \
	&& echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& echo "LANG=en_US.UTF-8" > /etc/locale.conf \
	&& locale-gen en_US.UTF-8 


# user and groups
ENV USER shakugan
ENV PASSWORD AliAly032230
RUN useradd -m $USER -p $(openssl passwd $PASSWORD) \
    && usermod -aG sudo $USER \
    && echo "${USER}:${PASSWORD}" | chpasswd \
    && echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && chsh -s /bin/bash $USER

# config xrdp
RUN adduser xrdp ssl-cert \
    && echo "#!/bin/sh\nexport XDG_SESSION_DESKTOP=cinnamon\nexport XDG_SESSION_TYPE=x11\nexport XDG_CURRENT_DESKTOP=X-Cinnamon\nexport XDG_CONFIG_DIRS=/etc/xdg/xdg-cinnamon:/etc/xdg" > /env \ 
    && chmod 555 /env \
    && echo "#!/bin/sh\n. /env\nexec dbus-run-session -- cinnamon-session" > /xstartup \
    && chmod +x /xstartup \
    && cp -f /xstartup /etc/xrdp/startwm.sh

# config vnc
RUN mkdir /home/$USER/.vnc \
    && echo $PASSWORD | vncpasswd -f > /home/$USER/.vnc/passwd \
    && chmod 0600 /home/$USER/.vnc/passwd \
    && chown -R $USER:$USER /home/$USER/.vnc \
    && cp -f /xstartup /home/$USER/.vnc/xstartup \
    && echo "#!/bin/sh\nsudo -u $USER -g $USER -- vncserver -rfbport 5902 -geometry 1920x1080 -depth 32 -verbose -localhost no -autokill no" > /startvnc \
    && chmod +x /startvnc

EXPOSE 6080 3389 5902

CMD service dbus start && /usr/lib/systemd/systemd-logind & service xrdp start && /startvnc && /usr/share/novnc/utils/launch.sh --listen 6080 --vnc localhost:5902 && bash
