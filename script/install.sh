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
scricptVer="21.2.1"

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
# 创建服务器 README.md 说明
function createSvrDoc() {
	readmePath=$ROOT_PATH/README.txt
	echo -e "# 文件夹说明\n---\n" >> $readmePath
	echo "## 文档结构" >> $readmePath
	echo "|-- .env       本机所有项目及公共配置文件夹" >> $readmePath
	echo "    └─ nginx       本机 Nginx 容器环境文件或应用配置文件" >> $readmePath
	echo "       └─ cert         nginx 容器的 SSL 证书文件夹" >> $readmePath
	echo "       └─ conf         配置文件数据盘" >> $readmePath
	echo "       └─ _letsencrypt 用于certBot 的校验文件存放文件夹" >> $readmePath
	echo "    └─ db          本机数据存容器环境文件或应用配置文件" >> $readmePath
	echo "       └─ mongo        mongoDb 数据卷" >> $readmePath
	echo "          └─ conf           配置文件夹" >> $readmePath
	echo "          └─ data            数据文件夹" >> $readmePath
	echo "       └─ mysql        mysqlDb 数据卷" >> $readmePath
	echo "          └─ conf            配置文件夹" >> $readmePath
	echo "          └─ data            数据文件夹" >> $readmePath
	echo "       └─ postgres     postgresDb 数据卷" >> $readmePath
	echo "          └─ conf            配置文件夹" >> $readmePath
	echo "          └─ data            数据文件夹" >> $readmePath
	echo "       └─ redis        redis 数据卷" >> $readmePath
	echo "          └─ conf            配置文件夹" >> $readmePath
	echo "          └─ data            数据文件夹" >> $readmePath
	echo "       └─ meilisearch  meilisearch 全文搜索引擎数据盘" >> $readmePath
	echo "          └─ conf            配置文件夹" >> $readmePath
	echo "          └─ data            数据文件夹" >> $readmePath
	echo "    └─ .nodeGlobal 工程级 NodeJs 全局库文件夹（匹配 NodeJs版本、python版本、）" >> $readmePath
	echo "       └─ (12/14/16/18) nodeJs 全局库的 bin 文件，npm/yarn/pnpm 公用" >> $readmePath
	echo "          └─ bin             nodeJs 全局库的 bin 文件，npm/yarn/pnpm 公用" >> $readmePath
	echo "          └─ npmRepo         基于 Npm 的全局库" >> $readmePath
	echo "             └─ cache           缓存文件夹" >> $readmePath
	echo "             └─ global          全局包文件夹" >> $readmePath
	echo "          └─ yarnRepo        基于 Yarn 的全局库" >> $readmePath
	echo "             └─ cache           缓存文件夹" >> $readmePath
	echo "             └─ global          全局包文件夹" >> $readmePath
	echo "             └─ link            全局链接文件夹" >> $readmePath
	echo "             └─ offlinel        全局离线缓存文件夹" >> $readmePath
	echo "          └─ pnpmRepo        基于 Pnpm 的全局库" >> $readmePath
	echo "             └─ cache           缓存文件夹" >> $readmePath
	echo "             └─ global          全局包文件夹" >> $readmePath
	echo "    └─ codeServer  svn 容器环境文件或应用配置文件" >> $readmePath
	echo "    └─ frp         gitLab 容器环境文件或应用配置文件" >> $readmePath
	echo "    └─ gitLab      svn 容器环境文件或应用配置文件" >> $readmePath
	echo "    └─ noVnc       gitLab 容器环境文件或应用配置文件" >> $readmePath
	echo "    └─ svn         svn 容器环境文件或应用配置文件" >> $readmePath
	echo "    └─ verdaccio   gitLab 容器环境文件或应用配置文件" >> $readmePath
	echo "-----------------------------------------------------" >> $readmePath
	echo "|-- .docker    本机 Docker 实例的镜像、容器、日志、数据卷等文件夹" >> $readmePath
	echo "-----------------------------------------------------" >> $readmePath
	echo "|-- .python     本机 python 数据卷" >> $readmePath
	echo "    └─ v2.7              v2.7 版本卷" >> $readmePath
	echo "    └─ v3.0              v3.0 版本卷" >> $readmePath
	echo "-----------------------------------------------------" >> $readmePath
	echo "|-- .logs       本机日志文件存储集合" >> $readmePath
	echo "    └─ [工程名称]     工程日志" >> $readmePath
	echo "    └─ nginx         nginx 日志" >> $readmePath
	echo "    └─ db            数据库日志" >> $readmePath
	echo "       └─ mongo           mongoDb 日志" >> $readmePath
	echo "       └─ mysql           mysqlDb 日志" >> $readmePath
	echo "       └─ postgres        postgresDb 日志" >> $readmePath
	echo "       └─ redis           redis 日志" >> $readmePath
	echo "       └─ meilisearch     meilisearch 全文搜索引擎日志" >> $readmePath
	echo "-----------------------------------------------------" >> $readmePath
	echo "|-- .backup     本机备份文件存储集合" >> $readmePath
	echo "    └─ [工程名称]     工程备份" >> $readmePath
	echo "       └─ wwww     web 页面文件备份" >> $readmePath
	echo "       └─ svr      后端服务文件备份" >> $readmePath
	echo "       └─ source   源码文件备份" >> $readmePath
	echo "       └─ design   设计文件备份" >> $readmePath
	echo "    └─ nginx       nginx 备份" >> $readmePath
	echo "    └─ db          数据库备份" >> $readmePath
	echo "       └─ mongo           mongoDb 备份" >> $readmePath
	echo "       └─ mysql           mysqlDb 备份" >> $readmePath
	echo "       └─ postgres        postgresDb 备份" >> $readmePath
	echo "       └─ redis           redis 备份" >> $readmePath
	echo "       └─ meilisearch     meilisearch 全文搜索引擎备份" >> $readmePath
	echo "-----------------------------------------------------" >> $readmePath
	echo "|-- common      本机公共资源集文件夹" >> $readmePath
	echo "    └─ .smpoo         深普品牌公共静态资源" >> $readmePath
	echo "-----------------------------------------------------" >> $readmePath
	echo "|-- scricpt     本机公用的运维脚本文件夹" >> $readmePath
	echo "-----------------------------------------------------" >> $readmePath
	echo "|-- tools       本机工具应用文件夹" >> $readmePath
	echo "   └─ codeServer     基于 vscode 的 codeServer 服务文件夹" >> $readmePath
	echo "   └─ frp            基于 frp 的内网穿透服务文件夹" >> $readmePath
	echo "   └─ gitLab         基于 gitLab 的私有 git 服务文件夹" >> $readmePath
	echo "   └─ noVnc          基于 noVnc 的 web 浏览器远程桌面服务文件夹" >> $readmePath
	echo "   └─ svn            私有 svn 服务文件夹" >> $readmePath
	echo "   └─ verdaccio      基于 Verdaccio 的私有 npm 库服务文件夹" >> $readmePath
	echo "-----------------------------------------------------" >> $readmePath
	echo "|-- project/[工程]    本机工程文件夹" >> $readmePath
	echo "   └─ data           工程数据文件夹" >> $readmePath
	echo "   └─ dockerFile     工程 dockerFile 文件夹" >> $readmePath
	echo "       └─ base                 基础镜像" >> $readmePath
	echo "       └─ biz                  业务镜像" >> $readmePath
	echo "       └─ tools                工具镜像" >> $readmePath
	echo "   └─ html           工程 web 文件夹" >> $readmePath
	echo "       └─ docs                 工程文档文件夹" >> $readmePath
	echo "       └─ files                工程上传下载的静态文件夹" >> $readmePath
	echo "       └─ www                  主 web 根文件夹" >> $readmePath
	echo "   └─ nodePj         工程内 nodeJs 程序文件夹" >> $readmePath
	echo "       └─ node_modules         工程内 nodeJs 库数据卷" >> $readmePath
	echo "       └─ space                monoRepo 文件夹" >> $readmePath
	echo "       └─ pnpm-workspace.yaml  monoRepo 配置文件" >> $readmePath
	echo "   └─ scricpt        仅本工程可用的脚本文件夹" >> $readmePath
	echo "" >> $readmePath
	echo "---" >> $readmePath
	echo -e "## 服务器可放行端口列表\n以下列表仅代表该服务器可能允许的端口，具体是否开放，由服务启动时自动管理" >> $readmePath
	echo "* ### 前端服务端口：80 443 8080 9999" >> $readmePath
	echo "* ### PC端程序后端服务端口：3000 3001 3002 3003 3004 3005 3006 3007 3008 3009" >> $readmePath
	echo "* ### 微信小程序后端服务端口：4100 4101 4102 4103" >> $readmePath
	echo "* ### 飞书应用后端服务端口：5100 5101 5102 5103 [应避免使用 5000 端口-(blazer5 木马 和 Troie ）]" >> $readmePath
	echo "* ### 业务接口端口：3999" >> $readmePath
	echo "* ### 微信机器人端口：4999" >> $readmePath
	echo "* ### 飞书机器人端口：5999" >> $readmePath
	echo "* ### Mysql 数据库接口：3306" >> $readmePath
	echo "* ### MongoDb 数据库接口 27017 28017" >> $readmePath
	echo "* ### SVN 接口 3690" >> $readmePath
	echo "* ### gitLab 新端口 8888" >> $readmePath
	echo "* ### NodeJs 项目远程调试端口 9229" >> $readmePath
	echo "* ### Cockpit WEB 端管理页面端口 9090" >> $readmePath
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
		dbTypes=(mongo mysql postgres redis meilisearch)

		# 在首次初始化时初始化根目录
		mkdir -pv $ROOT_PATH/.env/{nginx/{cert,conf,_letsencrypt},db,nodeGlobal,codeServer,frp,gitLab,noVnc,svn,verdaccio}
		mkdir -pv $ROOT_PATH/.docker
		mkdir -pv $ROOT_PATH/.python/{v2.7,v3.0}
		mkdir -pv $ROOT_PATH/.logs/{nginx,db}
		mkdir -pv $ROOT_PATH/.backup/{nginx,db}
		mkdir -pv $ROOT_PATH/common/.smpoo
		mkdir -pv $ROOT_PATH/project
		mkdir -pv $ROOT_PATH/scricpt
		mkdir -pv $ROOT_PATH/tools/{codeServer,frp,gitLab,noVnc,svn,verdaccio}

		# DB
		for ((i=0;i<${#dbTypes[*]};i++))
		do
			mkdir -pv $ROOT_PATH/.env/db/${dbTypes[$i]}/{conf,data}
		done

		# nodeJs 全局
		nodeVers=(v12 v14 v16 v18)
		for ((i=0;i<${#nodeVers[*]};i++))
		do
			mkdir -pv $ROOT_PATH/.env/.nodeGlobal/${nodeVers[$i]}/{bin,npmRepo/{cache,global},pnpmRepo/{cache,global},yarnRepo/{cache,globa,link,offlinel}}
		done

		# 日志
		mkdir -pv nginx
		for ((i=0;i<${#dbTypes[*]};i++))
		do
			mkdir -pv $ROOT_PATH/.logs/db/${dbTypes[$i]}
		done

		# 备份
		mkdir -pv nginx
		for ((i=0;i<${#dbTypes[*]};i++))
		do
			mkdir -pv $ROOT_PATH/.backup/db/${dbTypes[$i]}
		done

		# 公共资源集
		chmod 777 $ROOT_PATH/common
		# 工程文件夹
		chmod 777 $ROOT_PATH/project
		# 运维脚本集
		chmod 777 $ROOT_PATH/scricpt

		# 创建文件夹结构说明
		createSvrDoc
	fi

	mkdir -pv $ROOT_PATH/.logs/$PROJECT_NAME $ROOT_PATH/.backup/$PROJECT_NAME

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
	# 全局安装基本组件
	yum install -y git vim curl telnet telnet-server openssl-devel kernel-devel createrepo holland-mysqldump.noarch expect gcc gcc-c++ libevent-devel libxml2-devel jansson-devel m4 make ncurses-devel SDL tcl tcl-devel unixODBC unixODBC-devel glibc-common
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
	echo "\"data-root\": \"/$ROOT_PATH/.docker\"" >> /etc/docker/daemon.json
	echo "}" >> /etc/docker/daemon.json
	systemctl start docker.socket
	systemctl start docker
	docker -v

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
