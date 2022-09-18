#!/bin/sh

portVal=$1
if [ "$portVal" == "" ];
then
echo "命令行中必须传入要开启的端口号"
else
firewall-cmd --zone=public --permanent --add-port=$portVal/tcp
firewall-cmd --reload
echo "端口 $portVal  已开启"
fi