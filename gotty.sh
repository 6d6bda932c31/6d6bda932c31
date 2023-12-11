apt-get update && apt-get full-upgrade -y && apt-get -y dist-upgrade && apt-get -y autoremove && apt-get install -y wget curl build-essential software-properties-common

wget -O- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | apt-key add -
apt-add-repository --yes -s https://deb.torproject.org/torproject.org
apt-get update && apt-get install tor deb.torproject.org-keyring torsocks -y

sed -i 's\#SocksPort 9050\SocksPort 9055\ ' /etc/tor/torrc
sed -i 's\#ControlPort 9051\ControlPort 9054\ ' /etc/tor/torrc
sed -i 's\#HashedControlPassword\HashedControlPassword\ ' /etc/tor/torrc
sed -i 's\#CookieAuthentication 1\CookieAuthentication 1\ ' /etc/tor/torrc
sed -i 's\#HiddenServiceDir /var/lib/tor/hidden_service/\HiddenServiceDir /var/lib/tor/hidden_service/\ ' /etc/tor/torrc
sed -i '72s\#HiddenServicePort 80 127.0.0.1:80\HiddenServicePort 80 127.0.0.1:80\ ' /etc/tor/torrc
sed -i '73 i HiddenServicePort 22 127.0.0.1:22' /etc/tor/torrc
sed -i '74 i HiddenServicePort 8080 127.0.0.1:8080' /etc/tor/torrc
sed -i '75 i HiddenServicePort 4000 127.0.0.1:4000' /etc/tor/torrc
sed -i '76 i HiddenServicePort 8000 127.0.0.1:8000' /etc/tor/torrc
sed -i '77 i HiddenServicePort 9000 127.0.0.1:9000' /etc/tor/torrc
sed -i '78 i HiddenServicePort 3389 127.0.0.1:3389' /etc/tor/torrc
sed -i '79 i HiddenServicePort 5901 127.0.0.1:5901' /etc/tor/torrc
sed -i '80 i HiddenServicePort 5000 127.0.0.1:5000' /etc/tor/torrc
sed -i '81 i HiddenServicePort 6080 127.0.0.1:6080' /etc/tor/torrc
sed -i '82 i HiddenServicePort 8888 127.0.0.1:8888' /etc/tor/torrc
sed -i '83 i HiddenServicePort 8888 127.0.0.1:7777' /etc/tor/torrc
sed -i '84 i HiddenServicePort 12345 127.0.0.1:12345' /etc/tor/torrc
sed -i '85 i HiddenServicePort 10000 127.0.0.1:10000' /etc/tor/torrc
sed -i '86 i HiddenServicePort 40159 127.0.0.1:40159' /etc/tor/torrc

wget https://github.com/sorenisanerd/gotty/releases/download/v1.5.0/gotty_v1.5.0_linux_amd64.tar.gz && tar -xf gotty_v1.5.0_linux_amd64.tar.gz && rm -rf gotty_v1.5.0_linux_amd64.tar.gz && chmod +x gotty && mv gotty /usr/local/bin/gotty

rm -rf /var/lib/tor/hidden_service/*

echo "Starting tor ..."
echo > /etc/tor/log
tor -f /etc/tor/torrc | tee /etc/tor/log &

while ! grep -w 'Bootstrapped 100% (done): Done' /etc/tor/log  > /dev/null
do
    sleep 1
    echo ""
    sleep 1
done

USER="${TTY_USER:-ADMIN}"
PASS="${TTY_PASSWORD:-$(dd status=none if=/dev/urandom count=1 bs=16 | sha1sum | awk '{print $1}')}"
PORT="${TTY_PORT:-12345}"

echo USER: $USER
echo PASSWORD: $PASS
echo ONION ADRESS: http://$(cat /var/lib/tor/hidden_service/hostname):$PORT

gotty \
    --credential "${USER}:${PASS}" \
    --port ${PORT} --reconnect -w bash
