#!/bin/bash
source ./base.sh
source ./mkAlias.sh
source ./mkFolder.sh

clear

function getUbuntuInfo() {
	echo "Ubuntu 22.04.1 LTS"
}
# 服务宿主机已初始化
isDone=`checkDone`
showSysInfo "`getUbuntuInfo`"

if [ "$isDone" == "n" ]; then

	initFolder
	showInfo "WSL - Ubuntu 系统环境初始化中"
	mkClear
	echo -e "alias clear='/bin/sh /root/.clear.sh'" >> /root/.bashrc
	source /root/.bashrc

	# 更换中科大源
	if [ ! -f /etc/apt/sources.list.bak ]; then
		mv /etc/apt/sources.list /etc/apt/sources.list.bak
	fi

	cat >> /etc/apt/sources.list <<- EOF
		deb https://mirrors.ustc.edu.cn/ubuntu/ jammy main restricted universe multiverse
		deb-src https://mirrors.ustc.edu.cn/ubuntu/ jammy main restricted universe multiverse
		deb https://mirrors.ustc.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
		deb-src https://mirrors.ustc.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
		deb https://mirrors.ustc.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
		deb-src https://mirrors.ustc.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
		deb https://mirrors.ustc.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
		deb-src https://mirrors.ustc.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
		deb https://mirrors.ustc.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
		deb-src https://mirrors.ustc.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
	EOF
	apt update

	setDone
	isDone="y"
else
	createProjectFolder
	showSucc "WSL 系统已经初始化完成"
fi

showSmpooLogo
