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
isDone=`checkDone`
showSysInfo "`getAlpineInfo`"

if [ "$isDone" == "n" ]; then
	initFolder
	showInfo "WSL - Alpine 系统环境初始化中"
	mkClear
	echo -e "alias clear='/bin/sh /root/.clear.sh'" >> /root/.bashrc
	echo -e "alias ll='ls -laF'" >> /root/.bashrc
	source /root/.bashrc
	# 更换中科源
	sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
	#安装tzdata
	apk update && apk add --no-cache tzdata
	#拷贝时区文件
	cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
	#指定时区
	echo "Asia/Shanghai" > /etc/timezone
	#移除时区文件(指定完时区就可以删除了)
	apk del tzdata
	#查看时间及时区
	date -R

	setDone
	isDone="y"
else
	createProjectFolder
	showSucc "WSL 系统已经初始化完成"
fi

showSmpooLogo
