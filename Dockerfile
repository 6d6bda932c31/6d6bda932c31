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
	python3-pip tigervnc-xorg-extension x11vnc dbus-x11 novnc net-tools kde*

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
#RUN apt-get install -yq \
#	flatpak plasma-discover-backend-flatpak \
#	&& flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo \
#	&& flatpak install flathub org.mozilla.firefox -y
RUN add-apt-repository ppa:mozillateam/ppa -y \
    && echo -e '\nPackage: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1002' | tee /etc/apt/preferences.d/mozilla-firefox \
    && echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox \
    && apt-get update -qy \
    && apt-get install firefox -y

# Install node
ARG NODE_VERSION=20
RUN wget -O - https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash \
    && apt-get -y install nodejs \
    && npm i -g updates

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
	
# add my sys config files
ADD etc /etc

# set owner
RUN chown -R shakugan:shakugan /home/shakugan/.*

#USER shakugan

#WORKDIR /home/shakugan

# ports
EXPOSE 6080
EXPOSE 5900

# default command
CMD ["/usr/bin/supervisord","-n","-c","/etc/supervisor/supervisord.conf"]
