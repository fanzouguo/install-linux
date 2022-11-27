#!/bin/sh
source ./base.sh
source ./mkAlias.sh
source ./mkFolder.sh

clear

function getAlpineInfo() {
	cat /etc/os-release | while read line
	do
		if [[ "${line}" == 'PRETTY_NAME=*' ]]; then
			echo ${line} | sed 's/PRETTY_NAME=//'
		fi
	done
}
# 服务宿主机已初始化
isDone=`checkDone "alpine"`
showSysInfo "`getAlpineInfo`"

if [ "$isDone" == "n" ]; then
	initFolder
	showInfo "WSL - Alpine 系统环境初始化中"
	mkClear
	echo -e "alias clear='/bin/sh /root/.clear.sh'" >> /etc/profile
	echo -e "alias ll='ls -laF'" >> /etc/profile
	echo -e "alias docker='podman'" >> /etc/profile
	source /etc/profile
	# 更换中科大源
	sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
	apk update
	apk add sudo vim openrc podman python3 py3-pip
	# 安装 podman-compose
	pip3 install podman-compose
	rc-update add podman boot
	setDone "alpine"
	isDone="y"
else
	createProjectFolder
	showSucc "WSL 系统已经初始化完成"
fi

showSmpooLogo
