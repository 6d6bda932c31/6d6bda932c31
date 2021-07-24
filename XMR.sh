#!/bin/sh
## UPDATE ##

sudo apt install screen -y
sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt update -y && sudo apt upgrade -y && sudo apt-get install --reinstall systemd -y && sudo apt-get install sed -y
sudo apt-get install nano
## TOR ##
sudo apt-get install tor -y
sudo /etc/init.d/tor stop



sudo sed -i '18s/#SOCKSPort/SOCKSPort/ ' /etc/tor/torrc
sudo sed -i '57s/#ControlPort/ControlPort/ ' /etc/tor/torrc
sudo sed -i 's/#ORPort/ORPort/ ' /etc/tor/torrc
sudo sed -i 's\#HiddenServiceDir /var/lib/tor/other_hidden_service\HiddenServiceDir /var/lib/tor/other_hidden_service\ ' /etc/tor/torrc
sudo sed -i '75i\HiddenServicePort 4444 pool.minexmr.com:4444\ ' /etc/tor/torrc

sudo systemctl enable tor
sudo /etc/init.d/tor start
sudo cat /etc/tor/torrc


## XMR ##

wget https://github.com/xmrig/xmrig/releases/download/v6.13.1/xmrig-6.13.1-linux-x64.tar.gz && tar xf xmrig-6.13.1-linux-x64.tar.gz && cd xmrig-6.13.1 && rm -rf config.json && wget https://raw.githubusercontent.com/ceeb57f83688/xmrig/main/TOR/config.json
cd xmrig-6.13.1

## CONFIG ##

sudo sed -i '13s/true/false/ ' config.json
sudo sed -i '3s/true/false/ ' config.json
sudo sed -i '9d' config.json
sudo cat /var/lib/tor/other_hidden_service/hostname | sed '1s/^/9i /' | sed -i -f- config.json
sudo sed -i '9s/$/:4444",/ ' config.json 
sudo sed -i '9s|^|            "url": "|' config.json



chmod +x xmrig && ./xmrig


while [ 1 ]; do
sleep 3
done
sleep 999
