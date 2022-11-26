#/bin/sh

# 服务宿主机已初始化
isDone="n"
# 全局根路径
ROOT_PATH="/smpoo_file"
# 默认工程名称
PROJECT_NAME=""
# 脚本执行日期
EXEC_DATE=$(date "+%Y-%m-%d %H:%M:%S")
# 本机内网IP地址
ipStr=$(/sbin/ifconfig -a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | tr -d "addr:")
# 本脚本文件版本号（会在 pnpm build 时自动改变）
scricptVer="26.3.0"
# Docker-compose 是否安装成功
dockerComposeIsOk=""

# 本系统默认允许的端口
# 前端服务端口：80 443 8080
# SVN 接口 3690
# gitLab 新端口 8888
# Cockpit WEB 端管理页面端口 9090
ALLOW_PORT=(3690 8080 8888 9090)

# region 控制台函数库
# 打印宿主机系统信息
function showSysInfo() {
	showErr "=============================================================================="
	showErr "·                                                                            ·"
	showErr "·                      This scricpt is base on:                              ·"
	showErr "·                       -- CentOS 7.5+ 64bit --                               ·"
	showErr "·                                                                            ·"
	showErr "=============================================================================="
	osName=`cat /etc/redhat-release | awk -F ' Linux release ' '{print $1}'`
	echo ""
	echo ""
	echo  -e "\e[44;37;1m 操作系统类型: \e[0m" $osName
	echo ""
	echo 系统版本号：`cat /etc/redhat-release`
	echo 服务器日期：$EXEC_DATE
	echo 服务器 IP ：$ipStr
	echo 脚本版本号：$scricptVer
	echo "power by:   上海深普软件有限公司 - wwww.smpoo.com"
	showLine
	echo ""
	echo ""
}
# 打印深普品牌LOGO
function showSmpooLogo() {
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
# 重要警告（如清空、删除提示）
function showWarn() {
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
# 显示红色文字行
function showErr() {
	echo -e "\e[0;31;1m $1 \e[0m"
}
# 显示绿色文字行
function showSucc() {
	echo -e "\e[0;32;1m $1 \e[0m"
}
# 步骤结束提示
function stepDone() {
	# 输入100个等号
	showStr=$(printf '%6s\n' | tr ' ' .)
	showSucc $showStr"  $1完成  "$showStr
	echo ""
	echo ""
}
# 获取控制台屏显宽度
function getshellwidth() {
  echo `stty size|awk '{print $2}'`
  # return 0 # return是返回 成功或者失败的
  # 调用的时候只需要上面的输出就行， 他会将标准输出return回来
}
# 输出满屏横线
function showLine() {
  shellwidth=`getshellwidth`
  lineStr=` yes "-" | sed $shellwidth'q' | tr -d '\n'`
  echo $lineStr
}
# endregion

# region 流程函数库
# 脚本启动准备
function beforInit() {
	clear
	echo -e "\e[44;37;1m是否继续进行? [取消安装(n/N) | 其他任意键继续 ] \e[0m"
	read -n 1 -p "" isRight
	if echo "$isRight" | grep -qwi "n"
	then
		echo -e "\n\n安装已取消！\n"
		exit 1
	fi
	cd /root
}
# 目录结构准备
function preparePath() {
	if [ "$isDone" == "y" ]; then
		echo ""
		read -p $'请输入新的工程名称：\x0a' newPjName
		if [ ! -n "$newPjName" ]; then
			showErr "必须输入新的工程名称"
			exit 0
		else
			PROJECT_NAME="$newPjName"
		fi
	else
		PROJECT_NAME="tcoffe"
	fi

	echo ""
	echo ""
	echo "正在初始化目录"...

	mkdir -p $ROOT_PATH
	if [ "$isDone" != "y" ]; then
		dbTypes=(mongo mysql postgres redis meilisearch minio)
		toolsType=(codeServer firefoxSend frp gitLab noVnc svn verdaccio)

		# 在首次初始化时初始化根目录
		mkdir -pv $ROOT_PATH/.env/{nginx/{cert,conf,_letsencrypt},db,nodeGlobal,svn/repo}
		mkdir -pv $ROOT_PATH/docker
		mkdir -pv $ROOT_PATH/logs/{nginx,db}
		mkdir -pv $ROOT_PATH/backup/{nginx,db}
		mkdir -pv $ROOT_PATH/common/.smpoo
		mkdir -pv $ROOT_PATH/project
		mkdir -pv $ROOT_PATH/scricpt

		# DB
		for ((i=0;i<${#dbTypes[*]};i++))
		do
			mkdir -pv $ROOT_PATH/.env/db/${dbTypes[$i]}/{conf,data}
		done

		# Tools
		for ((i=0;i<${#toolsType[*]};i++))
		do
			mkdir -pv $ROOT_PATH/.env/${dbTypes[$i]}/{conf,data}
		done

		# nodeJs 全局
		nodeVers=(haya tmind tcoffe)
		for ((i=0;i<${#nodeVers[*]};i++))
		do
			mkdir -pv $ROOT_PATH/.env/nodeGlobal/${nodeVers[$i]}/{npmRepo/{cache,global},pnpmRepo/{cache,global,store},yarnRepo/{cache,global,link,offlinel}}
		done

		# 日志
		mkdir -pv nginx
		for ((i=0;i<${#dbTypes[*]};i++))
		do
			mkdir -pv $ROOT_PATH/logs/db/${dbTypes[$i]}
		done

		# 备份
		mkdir -pv nginx
		for ((i=0;i<${#dbTypes[*]};i++))
		do
			mkdir -pv $ROOT_PATH/backup/db/${dbTypes[$i]}
		done

		# 备份文件夹
		chmod -R 777 $ROOT_PATH/backup
		# 公共资源集
		chmod -R 777 $ROOT_PATH/common
		# 日志文件夹
		chmod -R 777 $ROOT_PATH/logs
		# 工程文件夹
		chmod -R 777 $ROOT_PATH/project
		# 运维脚本集
		chmod -R 777 $ROOT_PATH/scricpt
		# 运维工具集
		chmod -R 777 $ROOT_PATH/tools
	fi

	mkdir -pv $ROOT_PATH/logs/$PROJECT_NAME $ROOT_PATH/backup/$PROJECT_NAME

	mkdir -pv $ROOT_PATH/project/$PROJECT_NAME/data
	mkdir -pv $ROOT_PATH/project/$PROJECT_NAME/dockerFile
	mkdir -pv $ROOT_PATH/project/$PROJECT_NAME/html/{docs,files,www}
	mkdir -pv $ROOT_PATH/project/$PROJECT_NAME/nodePj/{node_modules,space}
	mkdir -pv $ROOT_PATH/project/$PROJECT_NAME/scricpt

	stepDone "目录结构初始化"
}
# 更改系统源阿里源
function changeSource() {
	showSucc "更换系统源"
	# 更换主源文件
	cd /etc/yum.repos.d/
	cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bk

	# CentOS-Base.repo 切换为科大源
	sudo sed -e 's|^mirrorlist=|#mirrorlist=|g' \
  -e 's|^#baseurl=http://mirror.centos.org|baseurl=http://mirrors.ustc.edu.cn|g' \
  -i.bak \
  /etc/yum.repos.d/CentOS-Base.repo
	rm -rf /var/cache/yum
	yum clean all
	yum -y makecache
	cd ~

	# 更改 EPEL
	yum install -y epel-release

	# epel.repo 切换为科大源
	sudo sed -e 's|^metalink=|#metalink=|g' \
	-e 's|^#baseurl=https\?://download.fedoraproject.org/pub/epel/|baseurl=https://mirrors.ustc.edu.cn/epel/|g' \
	-e 's|^#baseurl=https\?://download.example/pub/epel/|baseurl=https://mirrors.ustc.edu.cn/epel/|g' \
	-i.bak \
	/etc/yum.repos.d/epel.repo

	yum -y makecache
	yum -y update
	stepDone "系统源更为科大源"
}
# 系统环境预安装
function preInstall() {
	showSucc "系统环境预安装"
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
	# 准备 mysqldump 工具的安装源
	cd ~
	wget https://dev.mysql.com/get/mysql80-community-release-el8-1.noarch.rpm
	rpm -ivh mysql80-community-release-el8-1.noarch.rpm
	# 全局安装基本依赖库
	yum install -y createrepo curl-devel expect expat-devel gcc gcc-c++ gettext-devel glibc-common holland-mysqldump.noarch kernel-devel libevent-devel libxml2-devel jansson-devel m4 make ncurses-devel openssl-devel perl-ExtUtils-MakeMaker SDL tcl tcl-devel unixODBC unixODBC-devel zlib-devel
	# 全局安装基本组件
	yum install -y  curl git subversion telnet telnet-server vim
	#

	stepDone "系统环境预安装"
}
# 端口配置
function openPort() {
	showSucc "系统将开启以下端口："
	for subItem in ${ALLOW_PORT[*]}; do
		if [ $subItem -gt 0 ]; then
			echo "Port：$subItem"
			firewall-cmd --zone=public --permanent --add-port=$subItem/tcp
			# 防火墙重新加载，以便生效之前的放行
			firewall-cmd --reload
		fi
	done

	stepDone "系统端口规则配置"
}
# 安装 Docker
function installDocker() {
	showSucc "安装 Docker"
	# 卸载可能已安装过的旧版Docker(如果存在的话)
	yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine docker-ce
	# 设置 Docker 仓库
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
	echo "\"data-root\": \"/$ROOT_PATH/docker\"" >> /etc/docker/daemon.json
	echo "}" >> /etc/docker/daemon.json
	systemctl start docker.socket
	systemctl start docker

	# 安装 docker-compose
	wget "https://github.com/docker/compose/releases/download/v2.12.2/docker-compose-`uname -s`-`uname -m`" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose

	if [ -f /usr/local/bin/docker-compose ]; then
		dcVerCkb=`docker-compose --version`
		if [ "$dcVerCkb" == "Docker Compose version v*" ]; then
			dockerComposeIsOk="true"
			chmod +x /usr/local/bin/docker-compose
		else
			dockerComposeIsOk=""
		fi
	else
		dockerComposeIsOk=""
	fi
	stepDone "Docker 安装"
}
# 安装 cockpit
function installCockpit() {
	showSucc "安装 Cockpit"
	yum install -y cockpit cockpit-docker cockpit-machines cockpit-dashboard cockpit-storaged cockpit-packagekit
	systemctl enable --now cockpit
	firewall-cmd --permanent --zone=public --add-service=cockpit
	firewall-cmd --reload

	stepDone "Cockpit 安装"
}
# 初始化深普公共资源包
function initAssets() {
	showSucc "公共资源初始化"
	if [ "$isDone" != "y" ]; then
		cd /$ROOT_PATH/common/.smpoo
		wget -c https://cdn.jsdelivr.net/gh/fanzouguo/install-linux@main/assets/smpoo.tar.gz -O - | tar -xz
	fi

	# 获取默认文件
	cd $ROOT_PATH/project/$PROJECT_NAME/nodePj
	wget -c https://cdn.jsdelivr.net/gh/fanzouguo/install-linux@main/assets/pnpm.tar.gz -O - | tar -xz
	cd /$ROOT_PATH/project/$PROJECT_NAME/html/www
	wget -c https://cdn.jsdelivr.net/gh/fanzouguo/install-linux@main/assets/www.tar.gz -O - | tar -xz
	cd ~

	stepDone "公共资源初始化"
}
# 环境清理
function cleanEnv() {
	showSucc "环境清理"
	yum clean all
	yum -y autoremove

	stepDone "环境清理"
}
# 系统基础安全防护
function baseDefense() {
	# 账号权限管理
	# ssh密钥及授权
	# 禁用账号密码登录
	# 禁用root账号
	# 升级 openssh 到 8.8
	# 升级 openssl 到 1.1.1
	# 修复 Log4 漏洞
	# 更改默认端口：22、3306、5432

	chmod 700 /root/.ssh
	chmod 700 $ROOT_PATH/project/$PROJECT_NAME
	chmod 777 $ROOT_PATH
	echo ""
}
# 显示安装报告
function getReport() {
	showWarn "安装完成"
	# 显示安装报告
	showSucc "=============================================================================="
	showSucc "·                                                                            ·"
	showSucc "·                                安 装 报 告                                 ·"
	showSucc "·                                                                            ·"
	showSucc "=============================================================================="
	echo ""
	showLine
	showSucc 端口
	echo "业务或服务相关端口将在服务启动时，由程序自行管理，以下是当前已开启的端口"
	firewall-cmd --zone=public --list-ports
	echo ""
	echo ""
	showLine
	showSucc 字符集
	locale
	showSucc 资源包
	ls -laF /$ROOT_PATH/common/.smpoo
	cd ~
	showSucc "Docker 及组件"
	docker -v
	docker-compose --version
	cd ~

	if [ "$dockerComposeIsOk" == "" ]; then
		echo ""
		echo ""
		showLine
		showErr "docker-compose 安装失败，请手工执行以下操作："
		echo "cd /usr/local/bin"
		echo -e "wget \"https://github.com/docker/compose/releases/download/v2.12.2/docker-compose-\`uname -s\`-\`uname -m\`\""
		echo -e "mv docker-compose-\`uname -s\`-\`uname -m\` docker-compose"
		echo "chmod +x /usr/local/bin/docker-compose"
		echo "***************"
		echo "执行：docker-compose --version 检查是否安装成功"
		echo -e "\n\n"
	fi
}
# 执行安装
function fullInstall() {
	echo "执行安装"
	# 0.1 文件夹结构预处理，以默认项目命名：tcoffe 进行
	preparePath
	# 0.2 更改系统源为 科大源
	changeSource
	# 0.3 系统环境预安装
	preInstall
	# 0.4 安装 Docker
	installDocker
	# 0.5 安装 Cockpit
	installCockpit
	# 0.6 公共资源初始化
	initAssets
	# 0.7 端口配置
	openPort
	# 0.8 执行系统基础安全防护
	baseDefense
	# 0.9 显示安装报告
	getReport

	echo ""
	echo ""
	showSucc "安装已全部完成!"
	echo "$EXEC_DATE 执行服务器初始化" >> /.smpooInitDone
	chmod 444 /.smpooInitDone
	echo ""
	isDone="y"
}
function init() {
	showSysInfo
	# 如果已初始化标志文件 /.smpooInitDone 存在
	if [ -e /.smpooInitDone ]; then
		isDone="y"
		if [ -e /smpoo_disk ]; then
			ROOT_PATH="/smpoo_disk"
		fi
	else
		# 已初始化标志文件 /.smpooInitDone 不存在（可能已被删除）,但 /smpoo_disk 目录存在
		if [ -e /smpoo_disk ]; then
			isDone="y"
			ROOT_PATH="/smpoo_disk"
		else
			# 已初始化标志文件 /.smpooInitDone 不存在（可能已被删除）,但 /smpoo_file 目录存在，且 /smpoo_disk 目录不存在
			if [ -e /smpoo_file ]; then
				isDone="y"
			fi
		fi
	fi
}
# 加载任务菜单
function loadMenu() {
	echo ""
	echo ""
	if [ "$isDone" != "y" ]; then
		echo "选择安装任务："
		echo "1：全新初始化服务器"
	else
		echo '本宿主机已完成初始化，您可以继续以下操作：'
		echo "2：添加工程结构"
	fi
	echo "3(或回车)：退出"

	read -n 1 selectMenu
	case "$selectMenu" in
	"1")
		echo ""
		if [ -e $ROOT_PATH ]; then
			showWarn "警告：路径：$ROOT_PATH 已存在，继续操作将会造成已有文件丢失或被覆盖，除非您确认该操作的风险，否则请终止操作"
			read -p $'请输入 y/Y 继续，\x0a其他任意键终止操作\x0a' ignoreRisk
			if echo "$ignoreRisk" | grep -qwi "y"
			then
				echo ""
				showErr "操作将继续进行..."
				echo ""
			else
				exit 0
			fi

		fi
		echo ""
		read -n 1 -p $'若本宿主机是云服务器，且已挂载了云数据盘，请输入 y/Y\x0a否则输入 n/N\x0a或直接回车：\x0a' hasDataDisk
		if echo "$hasDataDisk" | grep -qwi "y"
		then
			ROOT_PATH="/smpoo_disk"
		fi
		echo ""
		fullInstall
		;;
	"2")
		preparePath
		echo "$EXEC_DATE 增加了工程文件夹: $PROJECT_NAME" >> /.smpooInitDone
		chmod 444 /.smpooInitDone
		;;
	*)
		exit 0
		;;
	esac
}
# endregion

# region 调度执行
beforInit
init
loadMenu

echo ""
showSmpooLogo
echo ""
echo ""
echo ""
echo ""
# endregion
