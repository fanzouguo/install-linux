#!/bin/sh

if [ ! -n "$1"  ]; then
	read -p $'请输入要开启的端口号：\x0a' portVal
	firewall-cmd --zone=public --permanent --add-port=$portVal/tcp
else
	firewall-cmd --zone=public --permanent --add-port=$currPort/tcp
fi

firewall-cmd --reload