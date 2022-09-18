#!/bin/bash
# Slowdns Instalation
# ==========================================
# Color
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
# ==========================================
clear
red='\e[1;31m'
green='\e[0;32m'
yell='\e[1;33m'
NC='\e[0m'
echo "Installing SSH Slowdns" | lolcat
echo "Progress..." | lolcat
sleep 3
wget https://raw.githubusercontent.com/khairunisya/multiws/main/slowdnss/hostdnss.sh && chmod +x hostdnss.sh &&  sed -i -e 's/\r$//' hostdnss.sh && ./hostdnss.sh
nameserver=$(cat /root/nsdomain)

# SSH SlowDNS
wget -qO- -O /etc/ssh/sshd_config https://raw.githubusercontent.com/khairunisya/multiws/main/slowdnss/sshd_config
systemctl restart sshd

apt install screen -y
apt install cron -y
apt install iptables -y
service cron reload
service cron restart
service iptables reload

cd /usr/local
wget https://golang.org/dl/go1.16.2.linux-amd64.tar.gz
tar xvf go1.16.2.linux-amd64.tar.gz
export GOROOT=/usr/local/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
cd /root
apt install git -y
git clone https://www.bamsoftware.com/git/dnstt.git temp
mv /root/temp /root/slowdns
rm -rf temp
cd /root/slowdns/dnstt-server
go build
./dnstt-server -gen-key -privkey-file /root/slowdns/dnstt-server/server.key -pubkey-file /root/slowdns/dnstt-server/server.pub
mv /root/slowdns/dnstt-server/server.key /root/.dns
mv /root/slowdns/dnstt-server/server.pub /root/.dns
rm -rf /etc/slowdns
mkdir -m 777 /etc/slowdns

cd /root
rm -rf slowdns

wget -q -O /etc/slowdns/sldns-server "https://raw.githubusercontent.com/khairunisya/multiws/main/slowdnss/sldns-server"
wget -q -O /etc/slowdns/sldns-client "https://raw.githubusercontent.com/khairunisya/multiws/main/slowdnss/sldns-client"

chmod +x /etc/slowdns/sldns-server
chmod +x /etc/slowdns/sldns-client
cd
wget -q -O /etc/systemd/system/client-sldns.service "https://raw.githubusercontent.com/khairunisya/multiws/main/slowdnss/client-sldns.service"
wget -q -O /etc/systemd/system/server-sldns.service "https://raw.githubusercontent.com/khairunisya/multiws/main/slowdnss/server-sldns.service"
cd
install client-sldns.service
cat > /etc/systemd/system/client-sldns.service << END
[Unit]
Description=Client SlowDNS By Jrtunnel
Documentation=https://www.jrtunnel.com
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/etc/slowdns/sldns-client -udp 8.8.8.8:53 --pubkey-file /root/.dns/server.pub $nameserver 127.0.0.1:22
Restart=on-failure

[Install]
WantedBy=multi-user.target
END
cd
install server-sldns.service
cat > /etc/systemd/system/server-sldns.service << END
[Unit]
Description=Server SlowDNS By Jrtunnel
Documentation=https://www.jrtunnel.com
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/etc/slowdns/sldns-server -udp :5300 -privkey-file /root/.dns/server.key $nameserver 127.0.0.1:22
Restart=on-failure

[Install]
WantedBy=multi-user.target
END
cd
chmod +x /etc/systemd/system/client-sldns.service
chmod +x /etc/systemd/system/server-sldns.service
pkill sldns-server
pkill sldns-client

iptables -I INPUT -p udp --dport 5300 -j ACCEPT
iptables -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload

systemctl daemon-reload
systemctl stop client-sldns
systemctl stop server-sldns
systemctl enable client-sldns
systemctl enable server-sldns
systemctl start client-sldns
systemctl start server-sldns
systemctl restart client-sldns
systemctl restart server-sldns
cd
