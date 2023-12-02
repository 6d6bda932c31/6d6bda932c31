#FROM debian:11
FROM ubuntu:22.04

# update and install software
RUN export DEBIAN_FRONTEND=noninteractive  \
	&& apt-get update -qy \
	&& apt-get full-upgrade -qy \
	&& apt-get dist-upgrade -qy \
	&& apt-get install -qy  \
        sudo supervisor git xz-utils apt-utils openssh-server build-essential software-properties-common \
	wget curl unzip openjdk-17-jdk openjdk-17-jre nano tigervnc-standalone-server tightvncserver \
	python3-pip tigervnc-xorg-extension x11vnc dbus-x11 dirmngr lsb-release ca-certificates \
        software-properties-common apt-transport-https novnc net-tools kde*

# Fix en_US.UTF-8
RUN apt-get install locales -qy \
	&& echo "LC_ALL=en_US.UTF-8" >> /etc/environment \
	&& echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& echo "LANG=en_US.UTF-8" > /etc/locale.conf \
	&& locale-gen en_US.UTF-8 

# Install Chrome
RUN echo 'deb http://dl.google.com/linux/chrome/deb/ stable main' > /etc/apt/sources.list.d/chrome.list \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && apt-get update -qy \
    && apt-get install -y google-chrome-stable

# Install firefox
ADD etc /etc
RUN rm -rf /etc/apt/sources.list.d/mozillateam-ubuntu-ppa-jammy.list \
    && rm -rf /etc/apt/trusted.gpg.d/mozillateam_ubuntu_ppa.gpg \
    && apt-add-repository --yes -s ppa:mozillateam/ppa \
    && apt-get update -qy \
    && apt-get install firefox -y

# Install node
ARG NODE_VERSION=20
RUN wget -O - https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash \
    && apt-get -y install nodejs \
    && npm i -g npm@latest 
    
# Install tor
RUN apt-add-repository --yes -s https://deb.torproject.org/torproject.org \
    && wget -O- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | apt-key add - \
#   && echo -e "deb https://deb.torproject.org/torproject.org $(lsb_release -sc) main \ndeb-src https://deb.torproject.org/torproject.org $(lsb_release -sc) main" > /etc/apt/sources.list.d/tor.list \
    && apt-get update && apt-get install tor deb.torproject.org-keyring torsocks -y

# Install nomachine
ENV NOMACHINE_PACKAGE_NAME nomachine_8.10.1_1_amd64.deb
ENV NOMACHINE_MD5 2367db57367e9b6cc316e72b437bffe6
RUN curl -fSL "http://download.nomachine.com/download/8.10/Linux/${NOMACHINE_PACKAGE_NAME}" -o nomachine.deb \
    && echo "${NOMACHINE_MD5} *nomachine.deb" | md5sum -c - && dpkg -i nomachine.deb \
    && sed -i '/DefaultDesktopCommand/c\DefaultDesktopCommand "/usr/bin/startplasma-x11"' /usr/NX/etc/node.cfg

# cleanup and fix
RUN apt-get autoremove --purge -qy \
	&& apt-get --fix-broken install \
	&& apt-get clean 

# shakugans and groups
RUN useradd -m -s /bin/bash shakugan \
    && usermod -append --groups sudo shakugan \
    && echo "shakugan:AliAly032230" | chpasswd \
    && echo "shakugan ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# TZ, aliases
ENV TZ=Etc/UTC
RUN cd /home/shakugan \
    && echo 'export TZ=/usr/share/zoneinfo/$TZ' >> .bashrc \
    && sed -i 's/#alias/alias/' .bashrc

# set owner
RUN chown -R shakugan:shakugan /home/shakugan/.*

#USER shakugan

#WORKDIR /home/shakugan

# ports
EXPOSE 6080
EXPOSE 5900
EXPOSE 4000

# default command
CMD ["/usr/bin/supervisord","-n","-c","/etc/supervisor/supervisord.conf"]
