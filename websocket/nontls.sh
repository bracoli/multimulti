#!/bin/bash
# Proxy For NO TLS
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
echo "Installing SSH Websocket None TLS by SSH Jrtunnel NETWORK" | lolcat
echo "Progress..." | lolcat
sleep 2
sleep 1
echo -e "[ ${green}INFO${NC} ] Downloading files... "
# Getting Proxy Template
wget -qc -O /usr/local/bin/ws-nontls https://raw.githubusercontent.com/khairunisya/multiws/main/websocket/ws-nontls.py
chmod +x /usr/local/bin/ws-nontls
echo -e " [INFO] Successfully"
sleep 1
# Installing Service
cat > /etc/systemd/system/ws-nontls.service << END
[Unit]
Description=Python Proxy Mod By SSNVPN
Documentation=https://t.me/jrtunnelssh
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/python -O /usr/local/bin/ws-nontls 8880
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

systemctl daemon-reload
systemctl enable ws-nontls
systemctl restart ws-nontls

