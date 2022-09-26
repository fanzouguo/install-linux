#!/bin/sh

# region 全局变量
# 基于本次安装的全局根路径
ROOT_PATH="smpoo_file"
# 本次安装所基于的项目名称
PROJECT_NAME="tcoffe"
if [ "$1" != "" ];
then
  PROJECT_NAME=$1
fi
# 基于本次安装的全局数据盘根路径（如果存在的话）
ROOT_DATA_PATH="smpoo_disk"
# 步骤计数器
stepCt=0
# NodeJs 版本
VER_NODE_JS=("16.17.0" "18.8.0")
# 本机内网IP地址
ipStr=$(/sbin/ifconfig -a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | tr -d "addr:")
# 本系统默认允许的端口
# 前端服务端口：80 443 8080 9999
# PC端程序后端服务端口：3000 3001 3002 3003 3004 3005 3006 3007 3008 3009
# 微信小程序后端服务端口：4100 4101 4102 4103
# 飞书应用后端服务端口：5100 5101 5102 5103 [应避免使用 5000 端口-(blazer5 木马 和 Troie ）]
# 业务接口端口：3999
# 微信机器人端口：4999
# 飞书机器人端口：5999
# Mysql 数据库接口：3306
# MongoDb 数据库接口 27017 28017
# SVN 接口 3690
# NodeJs 项目远程调试端口 9229
# Cockpit WEB 端管理页面端口 9090
ALLOW_PORT=(80 443 3306 27017 28017 3690 9229 3000 3001 3002 3003 3004 3005 3006 3007 3008 3999 4000 4001 4002 4003 4999 5100 5101 5102 5103 5999 8080 9090 9999)
# endregion

# region 全局函数库
# 启动准备
function prepareBoot() {
	clear
	cd /root
}
# 端口开放
function openPort() {
	echo "系统将开启以下端口："
	for subItem in ${ALLOW_PORT[*]}; do
		if [ $subItem -gt 0 ]; then
			echo "Port：$subItem"
			firewall-cmd --zone=public --permanent --add-port=$subItem/tcp
			# 防火墙重新加载，以便生效之前的放行
			firewall-cmd --reload
		fi
	done
}
# 重要提示
function tipFirst() {
	strLen=$(echo $1 | wc -L)
	sl=$(($strLen + 6))
	cmds="%"$sl"s"
	outs=$(printf $cmds | tr ' ' -)
	lineStr="\e[41;33;1m |$outs| \e[0m"
	lineStr2="\e[41;33;1m |  $1 >>>    | \e[0m"
	if [ $2 ]; then
		lineStr="\e[44;37;1m |$outs| \e[0m"
		lineStr2="\e[44;37;1m |  $1 >>>    | \e[0m"
	fi

	echo -e $lineStr
	echo -e $lineStr2
	echo -e $lineStr
}
# 操作提示
function tipOpt() {
	echo -e "\e[0;31;1m $1 \e[0m"
}
# 绿色提示
function tipGreen() {
	echo -e "\e[0;32;1m $1 \e[0m"
}
# 步骤结束提示
function tipFoot() {
	# 输入100个等号
	showStr=$(printf '%100s\n' | tr ' ' =)
	echo $showStr${steps[$stepCt]}"完成..."
	stepCt=$(($stepCt + 1))
}
# 打印品牌LOGO
function tipFinish() {
	echo  -e "\033[34m       ___           ___           ___           ___           ___      \033[0m"
	echo  -e "\033[34m      /\\  \\         /\\__\\         /\\  \\         /\\  \\         /\\  \\     \033[0m"
	echo  -e "\033[34m     /::\\  \\       /::|  |       /::\\  \\       /::\\  \\       /::\\  \\    \033[0m"
	echo  -e "\033[34m    /:/\\ \\  \\     /:|:|  |      /:/\\:\\  \\     /:/\\:\\  \\     /:/\\:\\  \\   \033[0m"
	echo  -e "\033[34m   _\\:\\-\\ \\  \\   /:/|:|__|__   /::\\-\\:\\  \\   /:/  \\:\\  \\   /:/  \\:\\  \\  \033[0m"
	echo  -e "\033[34m  /\\ \\:\\ \\ \\__\\ /:/ |::::\\__\\ /:/\\:\\ \\:\\__\\ /:/__/ \\:\\__\\ /:/__/ \\:\\__\\  \033[0m"
	echo  -e "\033[34m  \\:\\ \\:\\ \\/__/ \\/__/--/:/  / \\/__\\:\\/:/  / \\:\\  \\ /:/  / \\:\\  \\ /:/  /  \033[0m"
	echo  -e "\033[34m   \\:\\ \\:\\__\\         /:/  /       \\::/  /   \\:\\  /:/  /   \\:\\  /:/  /  \033[0m"
	echo  -e "\033[34m    \\:\\/:/  /        /:/  /         \\/__/     \\:\\/:/  /     \\:\\/:/  /   \033[0m"
	echo  -e "\033[34m     \\::/  /        /:/  /                     \\::/  /       \\::/  /    \033[0m"
	echo  -e "\033[34m      \\/__/         \\/__/                       \\/__/         \\/__/     \033[0m"
	echo ""
	echo  -e "\033[34m                        上海深普软件有限公司 - www.smpoo.com \033[0m"
}
# 获取控制台屏显宽度
function getshellwidth() {
  echo `stty size|awk '{print $2}'`
  # return 0 # return是返回 成功或者失败的
  # 调用的时候只需要上面的输出就行， 他会将标准输出return回来
}
# 输出满屏横线
function getLine() {
  shellwidth=`getshellwidth`
  lineStr=` yes "-" | sed $shellwidth'q' | tr -d '\n'`
  echo $lineStr
}
# 打印品牌
function getBrand() {
	tipOpt "=============================================================================="
	tipOpt "·                                                                            ·"
	tipOpt "·                      This scricpt is base on:                              ·"
	tipOpt "·                       -- CentOS 7.5 64bit --                               ·"
	tipOpt "·                                                                            ·"
	tipOpt "=============================================================================="
	osName=`cat /etc/redhat-release | awk -F ' Linux release ' '{print $1}'`
	echo ""
	echo ""
	echo  -e "\e[44;37;1m 当前系统版本: \e[0m"
	echo $osName
	cat /etc/redhat-release
	echo ""
	echo ""
}
# 更改系统源阿里源
function changeSource() {
	# 更换主源文件
	cd /etc/yum.repos.d/
	mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bk
	# 163 源
	# wget http://mirrors.163.com/.help/CentOS7-Base-163.repo
	# 阿里源
	# wget -O /etc/yum.repos.d/CentOS-Base-epel.repo http://mirrors.aliyun.com/repo/Centos-7.repo
	# 科大源
	wget -O /etc/yum.repos.d/CentOS-Base-epel.repo http://mirrors.yangxingzhen.com/help/CentOS7-Base-zju.repo
	yum clean all
	rm -rf /var/cache/yum
	mv CentOS7-Base-163.repo CentOS-Base.repo
	yum -y makecache
	cd ~

	# 更改 EPEL
	yum install -y epel-release
	# 切换为阿里云
	# sudo sed -i.bak \
	# -e 's|^metalink|#metalink|' \
	# -e 's|^#baseurl=|baseurl=|' \
	# -e 's|download.fedoraproject.org/pub|mirrors.aliyun.com|' \
	# /etc/yum.repos.d/epel*.repo

	# 切换为科大源
	sudo sed -e 's|^metalink=|#metalink=|g' \
	-e 's|^#baseurl=https\?://download.fedoraproject.org/pub/epel/|baseurl=https://mirrors.ustc.edu.cn/epel/|g' \
	-e 's|^#baseurl=https\?://download.example/pub/epel/|baseurl=https://mirrors.ustc.edu.cn/epel/|g' \
	-i.bak \
	/etc/yum.repos.d/epel.repo

	yum -y makecache
	yum -y update
}
# 预处理操作系统环境
function prepareSysParam() {
	# 关闭seinux
	sed -i -e "s#SELINUX=.*#SELINUX=disabled#" /etc/selinux/config
	setenforce 0
	systemctl enable firewalld
	systemctl start firewalld.service
	#
	# 为系统添加DNS 和用户
	echo "nameserver 8.8.8.8" >>/etc/resolv.conf
	echo "nameserver 8.8.4.4" >>/etc/resolv.conf
	# 安装 config-manager 插件 和 中文字符集
	yum install -y yum-utils device-mapper-persistent-data lvm2 langpacks-zh_CN
	yum config-manager --set-enabled powertools
	# 全局安装基本组件
	yum install -y git vim curl telnet telnet-server openssl-devel kernel-devel createrepo expect gcc gcc-c++ libevent-devel libxml2-devel jansson-devel m4 make ncurses-devel SDL tcl tcl-devel unixODBC unixODBC-devel glibc-common
	#
}
# 预准备项目文件夹和用户
function preparePath() {
	mkdir -p /root/.ssh
	# mkdir -pv kkkk/{bbbb/{yyyy,mmmm},cccc/{eeeee,ffff}}
	PROJECT_ROOT="/$ROOT_PATH/$PROJECT_NAME"
	# 公共环境路径（所有类型管理员均具有读写权限，仅 root 具有删除权限）
	mkdir -p -m 777 "/$ROOT_PATH/common/.env"
	# SSL 证书存放路径（所有类型管理员均具有读写权限，仅 root 具有删除权限）
	mkdir -p -m 777 "/$ROOT_PATH/common/.env/nginx/cert"
	# SSL 自签名代理验证路径
	mkdir -p -m 777 "/$ROOT_PATH/common/.env/nginx/_letsencrypt"
	# NINGX 配置存放路径
	mkdir -p -m 777 "/$ROOT_PATH/common/.env/nginx/conf"
	# 数据库的库文件路径（仅DB管理员有读写权限，但不具备删除权限，仅 root 具有删除权限）
	mkdir -p -m 777 "/$ROOT_PATH/common/.db/mysql"
	mkdir -p -m 777 "/$ROOT_PATH/common/.db/mongo"
	mkdir -p -m 777 "/$ROOT_PATH/common/.db/redis"
	mkdir -p -m 777 "/$ROOT_PATH/common/.db/postgres"
	# Docker 镜像文件仓库（所有管理员类型账号均有权限）
	mkdir -p -m 777 "/$ROOT_PATH/common/.docker/image"
	# 网页备份文件存放路径（仅备份管理员具有读写权限，但不具备删除权限，仅 root 具有删除权限）
	mkdir -p -m 777 "/$ROOT_PATH/backup/www/$PROJECT_NAME"
	# 数据库备份文件存放路径（仅备份管理员具有读写权限，但不具备删除权限，仅 root 具有删除权限）
	mkdir -p -m 777 "/$ROOT_PATH/backup/db/$PROJECT_NAME"
	# [uploadFiles]：程序运行时上传文件的存放路径（仅 root 和开发、运维具有权限）
	# [uploadFiles/.smpoo]：默认的 logo\favicon.ico\50x.html 等文件缓存
	mkdir -p -m 777 "/$PROJECT_NAME/data/uploadFiles/.smpoo"
	# 基于项目的文档根地址（仅 root 和开发、运维具有权限）
	mkdir -p -m 777 "/$PROJECT_NAME/doc"
	# nginx 日志文件路径（仅 root 和开发、运维具有权限）
	mkdir -p -m 777 "/$PROJECT_ROOT/logs/nginx"
	# mysql 数据库日志文件路径（仅 root 和开发、运维具有权限）
	mkdir -p -m 777 "/$PROJECT_ROOT/logs/db/mysql"
	# mongoDb 数据库日志文件路径（仅 root 和开发、运维具有权限）
	mkdir -p -m 777 "/$PROJECT_ROOT/logs/db/mongo"
	# redis 数据库日志文件路径（仅 root 和开发、运维具有权限）
	mkdir -p -m 777 "/$PROJECT_ROOT/logs/db/redis"
	# postgreSql 数据库日志文件路径（仅 root 和开发、运维具有权限）
	mkdir -p -m 777 "/$PROJECT_ROOT/logs/db/postgres"
	# 后端服务运行时日志文件路径（仅 root 和开发、运维具有权限）
	mkdir -p -m 777 "/$PROJECT_ROOT/logs/project/adminSvr"
	mkdir -p -m 777 "/$PROJECT_ROOT/logs/project/authSvr"
	mkdir -p -m 777 "/$PROJECT_ROOT/logs/project/bizSvr"
	mkdir -p -m 777 "/$PROJECT_ROOT/logs/project/fileSvr"
	mkdir -p -m 777 "/$PROJECT_ROOT/logs/project/ioSvr"
	mkdir -p -m 777 "/$PROJECT_ROOT/logs/project/mailSvr"
	mkdir -p -m 777 "/$PROJECT_ROOT/logs/project/smsSvr"
	mkdir -p -m 777 "/$PROJECT_ROOT/logs/project/mockSvr"
	# 项目文件夹
	mkdir -p -m 777 "/$PROJECT_ROOT/project/nodejs"
	# 基于本次项目的 dockerFile 文件夹
	mkdir -p -m 777 "/$PROJECT_ROOT/dockerFile"
	# 网页 web 服务文件根地址（仅 root 和开发、运维具有权限）
	mkdir -p -m 777 "/$PROJECT_ROOT/html/www"
	# 为系统添加 prod 和 dev 用户
	adduser dev
	adduser prod
}
# 安装 Docker
function installDocker() {
	# 卸载可能已安装过的旧版Docker(如果存在的话)
	yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine docker-ce
	# 设置 Docker 仓库
	# 官方仓库
	# yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
	# 阿里云仓库
	# yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
	# 科大仓库
	yum-config-manager --add-repo https://mirrors.ustc.edu.cn/docker-ce/linux/centos/docker-ce.repo

	yum -y makecache fast
	# 开始安装
	yum install -y docker-ce
	systemctl start docker
	systemctl enable docker
	systemctl stop docker.socket
	systemctl stop docker
	# 修改镜像存储位置
	touch /etc/docker/daemon.json
	echo "{" >> /etc/docker/daemon.json
	echo "\"data-root\": \"/smpoo_file/common/.docker/image\"" >> /etc/docker/daemon.json
	echo "}" >> /etc/docker/daemon.json
	systemctl start docker.socket
	systemctl start docker
	docker -v
}
# 安装 cockpit
function installCockpit() {
	yum install -y cockpit cockpit-docker cockpit-machines cockpit-dashboard cockpit-storaged cockpit-packagekit
	systemctl enable --now cockpit
	firewall-cmd --permanent --zone=public --add-service=cockpit
	firewall-cmd --reload
}
# 环境清理
function cleanEnv() {
	tipGreen "环境清理"
	yum clean all
	yum -y autoremove
	# 根文件夹授权
	chmod -R 777 "/"$ROOT_PATH
}
# 显示安装报告
function echoReport() {
	tipFirst "安装完成"
	# 显示安装报告
	tipGreen "=============================================================================="
	tipGreen "·                                                                            ·"
	tipGreen "·                                安 装 报 告                                 ·"
	tipGreen "·                                                                            ·"
	tipGreen "=============================================================================="
	echo ""
	getLine
	tipGreen 端口
	firewall-cmd --zone=public --list-ports
	echo ""
	echo ""
	getLine
	tipGreen 字符集
	locale

	# 输出 SMPOO_LOGO
	tipFinish
	echo ""
	echo ""
	echo ""
	echo ""
}
# endregion

echo -e "\e[44;37;1m是否继续进行? [安装(y 或回车)| 取消安装(n)] \e[0m"
read -p "" isRight
case $isRight in
n)
	echo "安装已取消！"
	exit 1
	;;

esac

prepareBoot
echo "安装开始执行 ......"
# 0.1 更改系统源为 阿里源
changeSource
# 0.0 预处理操作系统环境
prepareSysParam
# 0.2 文件夹结构预处理
preparePath
# 0.3 端口开放
openPort
# 0.4 安装 Docker
installDocker
# 0.5 安装 Cockpit
installCockpit
# 0.9 显示安装报告
echoReport
