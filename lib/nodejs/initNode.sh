#!/bin/sh

# NodeJs 版本
VER_NODE_JS="v14.15.4"

# 操作提示
function tipOpt() {
	echo -e "\e[0;31;1m $1 \e[0m"
}

# Step5： 安装NodeJs
tipOpt ${steps[$stepCt]}
echo "准备安装 NodeJs: "$VER_NODE_JS
nodeFileName="node-"$VER_NODE_JS"-linux-x64"
wget "https://nodejs.org/dist/"$VER_NODE_JS"/"$nodeFileName".tar.xz"
tar -xvf $nodeFileName".tar.xz"
mv "/root/"$nodeFileName /usr/local/nodejs
echo 'export PATH=$PATH:/usr/local/nodejs/bin' >> /etc/profile
source /etc/profile

echo '==========================='
echo '              NodeJs 版本'
node -v
echo '==========================='

echo '==========================='
echo '              NPM 版本'
npm -v
echo '==========================='
tipFoot