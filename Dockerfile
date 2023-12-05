#FROM ubuntu:jammy-20230425
FROM ubuntu:lunar-20230615

# RUN apt update && \
#     DEBIAN_FRONTEND=noninteractive apt install -y cinnamon locales sudo

# RUN apt update && \
#     DEBIAN_FRONTEND=noninteractive apt install -y cinnamon-desktop-environment locales sudo

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y ubuntucinnamon-desktop locales sudo

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y xrdp tigervnc-standalone-server novnc && \
    adduser xrdp ssl-cert && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

ARG USER=shakugan
ARG PASS=1AliAly032230

RUN useradd -m $USER -p $(openssl passwd $PASS) && \
    usermod -aG sudo $USER && \
    chsh -s /bin/bash $USER

RUN echo "#!/bin/sh\n\
export XDG_SESSION_DESKTOP=cinnamon\n\
export XDG_SESSION_TYPE=x11\n\
export XDG_CURRENT_DESKTOP=X-Cinnamon\n\
export XDG_CONFIG_DIRS=/etc/xdg/xdg-cinnamon:/etc/xdg" > /env && chmod 555 /env

RUN echo "#!/bin/sh\n\
. /env\n\
exec dbus-run-session -- cinnamon-session" > /xstartup && chmod +x /xstartup

RUN mkdir /home/$USER/.vnc && \
    echo $PASS | vncpasswd -f > /home/$USER/.vnc/passwd && \
    chmod 0600 /home/$USER/.vnc/passwd && \
    chown -R $USER:$USER /home/$USER/.vnc

RUN cp -f /xstartup /etc/xrdp/startwm.sh && \
    cp -f /xstartup /home/$USER/.vnc/xstartup

RUN echo "#!/bin/sh\n\
sudo -u $USER -g $USER -- vncserver -rfbport 5902 -geometry 1920x1080 -depth 24 -verbose -localhost no -autokill no" > /startvnc && chmod +x /startvnc

EXPOSE 6080
EXPOSE 3389
EXPOSE 5902

CMD service dbus start && /usr/lib/systemd/systemd-logind & service xrdp start && /startvnc && /usr/share/novnc/utils/launch.sh --listen 6080 --vnc localhost:5902 && bash
