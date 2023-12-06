FROM ubuntu:jammy

# update and install software
RUN export DEBIAN_FRONTEND=noninteractive  \
	&& apt-get update -qy \
	&& apt-get full-upgrade -qy \
	&& apt-get dist-upgrade -qy \
	&& apt-get install -qy \
        sudo supervisor wget curl unzip tar git xz-utils apt-utils openssh-server build-essential software-properties-common \
        openjdk-17-jdk openjdk-17-jre nano tigervnc-standalone-server tightvncserver python3-pip tigervnc-xorg-extension \
        x11vnc dbus-x11 lsb-release ca-certificates apt-transport-https novnc net-tools cinnamon* xrdp

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
    && touch env \
    && sed -i '1 i #!/bin/sh' /env \
    && sed -i '2 i export XDG_SESSION_DESKTOP=cinnamon' /env \
    && sed -i '3 i export XDG_SESSION_TYPE=x11' /env \
    && sed -i '4 i export XDG_CURRENT_DESKTOP=X-Cinnamon' /env \
    && sed -i '5 i export XDG_CONFIG_DIRS=/etc/xdg/xdg-cinnamon:/etc/xdg' /env \
    && chmod 555 /env \
    && touch xstartup \
    && sed -i '1 i #!/bin/sh' /xstartup \
    && sed -i '2 i . /env' /xstartup \
    && sed -i '3 i exec dbus-run-session -- cinnamon-session' /xstartup \
    && chmod +x /xstartup \
    && cp -f /xstartup /etc/xrdp/startwm.sh

# config vnc
RUN mkdir /home/$USER/.vnc && \
    echo $PASSWORD | vncpasswd -f > /home/$USER/.vnc/passwd && \
    chmod 0600 /home/$USER/.vnc/passwd && \
    chown -R $USER:$USER /home/$USER/.vnc \
    && cp -f /xstartup /home/$USER/.vnc/xstartup \
    && touch startvnc \
    && sed -i '1 i #!/bin/sh' /startvnc \
    && sed -i '2 i sudo -u ${USER} -g ${USER} -- vncserver -rfbport 5902 -geometry 1920x1080 -depth 24 -verbose -localhost no -autokill no' /startvnc \
    && chmod +x /startvnc

EXPOSE 6080 3389 5902

CMD service dbus start && /usr/lib/systemd/systemd-logind & service xrdp start && /startvnc && /usr/share/novnc/utils/launch.sh --listen 6080 --vnc localhost:5902 && bash
