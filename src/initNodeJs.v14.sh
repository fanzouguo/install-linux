#! /bin/bash

VER_NUM = "v14.17.6"
# 安装 nodeJs
echo "准备安装 NodeJs: "$VER_NUM
cd /root

wget "https://nodejs.org/dist/"$VER_NUM"/node-"$VER_NUM"-linux-x64.tar.xz"
tar -xvf "node-"$VER_NUM"-linux-x64.tar.xz"
cd /usr/local/
mv "/root/node-"$VER_NUM"-linux-x64 ."
mv "node-"$VER_NUM"-linux-x64 nodejs"
echo 'export PATH=$PATH:/usr/local/nodejs/bin' >> /etc/profile
source /etc/profile
node -v
npm -v