#! /bin/bash

# 安装 nodeJs v10.16.1
cd /root
wget https://nodejs.org/dist/v10.16.1/node-v10.16.1-linux-x64.tar.xz
tar -xvf node-v10.16.1-linux-x64.tar.xz
cd /usr/local/
mv /root/node-v10.16.1-linux-x64 .
mv node-v10.16.1-linux-x64 nodejs
echo 'export PATH=$PATH:/usr/local/nodejs/bin' >> /etc/profile
source /etc/profile
node -v
npm -v