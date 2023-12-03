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
    && apt-get install -y google-chrome-stable \
    && rm -rf /etc/apt/sources.list.d/chrome.list

# Install firefox
ADD etc /etc
RUN apt-add-repository --yes -s ppa:mozillateam/ppa \
    && echo '\nPackage: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001' | tee /etc/apt/preferences.d/mozilla-firefox \
    && echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox \
    && apt-get update -qy \
    && apt-get install firefox -y

# Install node
ARG NODE_VERSION=20
RUN wget -O - https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash \
    && apt-get -y install nodejs \
    && npm i -g npm@latest 
    
# Install tor
RUN wget -O- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | apt-key add - \
    && apt-add-repository --yes -s https://deb.torproject.org/torproject.org \
    && apt-get update \
    && apt-get install tor deb.torproject.org-keyring torsocks -y \
    && sed -i 's\#SocksPort 9050\SocksPort 9058\ ' /etc/tor/torrc \
    && sed -i 's\#ControlPort 9051\ControlPort 9059\ ' /etc/tor/torrc \
    && sed -i 's\#HashedControlPassword\HashedControlPassword\ ' /etc/tor/torrc \
    && sed -i 's\#CookieAuthentication 1\CookieAuthentication 1\ ' /etc/tor/torrc \
    && sed -i 's\#HiddenServiceDir /var/lib/tor/hidden_service/\HiddenServiceDir /var/lib/tor/hidden_service/\ ' /etc/tor/torrc \
    && sed -i '72s\#HiddenServicePort 80 127.0.0.1:80\HiddenServicePort 80 127.0.0.1:80\ ' /etc/tor/torrc \
    && sed -i '73 i HiddenServicePort 22 127.0.0.1:22' /etc/tor/torrc \
    && sed -i '74 i HiddenServicePort 8080 127.0.0.1:8080' /etc/tor/torrc \
    && sed -i '75 i HiddenServicePort 4000 127.0.0.1:4000' /etc/tor/torrc \
    && sed -i '76 i HiddenServicePort 8000 127.0.0.1:8000' /etc/tor/torrc \
    && sed -i '77 i HiddenServicePort 9000 127.0.0.1:9000' /etc/tor/torrc \
    && sed -i '78 i HiddenServicePort 3389 127.0.0.1:3389' /etc/tor/torrc \
    && sed -i '79 i HiddenServicePort 5901 127.0.0.1:5901' /etc/tor/torrc \
    && sed -i '80 i HiddenServicePort 5000 127.0.0.1:5000' /etc/tor/torrc \
    && sed -i '81 i HiddenServicePort 6080 127.0.0.1:6080' /etc/tor/torrc \
    && sed -i '82 i HiddenServicePort 8888 127.0.0.1:8888' /etc/tor/torrc \
    && sed -i '83 i HiddenServicePort 8888 127.0.0.1:7777' /etc/tor/torrc \
    && sed -i '84 i HiddenServicePort 12345 127.0.0.1:12345' /etc/tor/torrc \
    && sed -i '85 i HiddenServicePort 10000 127.0.0.1:10000' /etc/tor/torrc \
    && sed -i '86 i HiddenServicePort 40159 127.0.0.1:40159' /etc/tor/torrc \
    && service tor start

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

WORKDIR /home/shakugan

# command nomachine
ADD nxserver.sh /home/shakugan/nxserver.sh
RUN chmod +x /home/shakugan/nxserver.sh

# ports
EXPOSE 6080 5900 4000

# default command
CMD ["/usr/bin/supervisord","-n","-c","/etc/supervisor/supervisord.conf"]
