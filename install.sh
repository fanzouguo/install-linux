#!/bin/sh

# This is newth version.

# 全局参数
# 默认主路径
dfDirName="smpoo_file"
# 步骤计数器
stepCt=0
# NodeJs 版本
VER_NODE_JS="v14.15.4"
# 本机内网IP地址
ipStr=$(/sbin/ifconfig -a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | tr -d "addr:")
#

# 全局函数库
# 检查端口
function ckPort() {
	item=$1
	for subItem in ${item[*]}; do
		if [ $subItem -gt 0 ]; then
			echo "根据安装选项，将自动开启端口：$subItem"
			firewall-cmd --zone=public "--add-port=$subItem/tcp" --permanent
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
#

clear
# 0 版本提示
tipOpt "=============================================================================="
tipOpt "·                                                                            ·"
tipOpt "·                      This scricpt is base on:                              ·"
tipOpt "·                       -- CentOS 8 64bit --                               ·"
tipOpt "·                                                                            ·"
tipOpt "=============================================================================="
osName=`cat /etc/redhat-release | awk -F ' Linux release ' '{print $1}'`
releasetmp=`cat /etc/redhat-release | awk '{match($0,"release ")
print substr($0,RSTART+RLENGTH)}' | awk -F '.' '{print $1}'`
echo ""
echo ""
echo  -e "\e[44;37;1m 当前系统版本: \e[0m"
cat /etc/redhat-release
echo ""
echo ""
echo -e "\e[44;37;1m 是否正确： ?[安装(y 或回车)| 取消安装(n)] \e[0m"
read -p "" isRight
case $isRight in
n)
	echo "安装已取消！"
	exit 1
	;;

esac
#

echo "执行安装...."
cd /root
# 0.1 预下载SQL预处理脚本
wget https://cdn.jsdelivr.net/gh/fanzouguo/install-linux@main/lib/sql/initSql.sh
chmod +x ./initSql.sh

# 0.1 更改系统源为 163 源
# 更换主源文件
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bk
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-8.repo
sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo
sudo sed -i.bak \
-e 's|^mirrorlist=|#mirrorlist=|' \
-e 's|^#baseurl=|baseurl=|' \
-e 's|http://mirror.centos.org|https://mirrors.aliyun.com|' \
/etc/yum.repos.d/CentOS-*.repo
sudo dnf makecache

# 更改 EPEL
sudo dnf install -y epel-release
sudo sed -i.bak \
-e 's|^metalink|#metalink|' \
-e 's|^#baseurl=|baseurl=|' \
-e 's|download.fedoraproject.org/pub|mirrors.aliyun.com|' \
/etc/yum.repos.d/epel*.repo
sudo dnf makecache

# 添加 dnf fastest mirror
sed -i '$a fastestmirror=True' /etc/dnf/dnf.conf

# sudo dnf clean metadata
# sudo dnf clean all
# sudo dnf makecache
sudo dnf -y update
#

# 0.2 关闭seinux
sed -i "s#SELINUX=.*#SELINUX=disabled#" /etc/selinux/config
setenforce 0
systemctl enable firewalld
systemctl start firewalld.service
#

# 0.3 为系统添加DNS,以避免 类似mongoDB的国外源更新失败
# 备用全局 Linux 资源地址
echo "nameserver 8.8.8.8" >>/etc/resolv.conf
#

# 0.4 全局安装基本组件
sudo dnf install -y git createrepo curl expect openssl-devel libevent-devel libxml2-devel jansson-devel epel-release gcc gcc-c++ kernel-devel m4 make ncurses-devel openssl-devel SDL telnet-server telnet tcl tcl-devel unixODBC unixODBC-devel vim yum-utils
# pygpgme tclx wxBase wxGTK wxGTK-gl
#

# 步骤列表
echo "环境初始化(Env_init) | 安装Nginx | 安装Mysql | 安装PostgreSql"

steps=("Env_init" "install_Nginx" "install_Mysql" "install_PostgreSql" "install_NodeJs")
ports=("-1" "80" "3306" "5432" "-1")
# 步骤选择结果
stepResult=(0 0 0 0 0)

clear

echo "标准主路径："$dfDirName
for item in ${steps[*]}; do
	stepResult[$stepCt]=1
	ckPort "${ports[$stepCt]}"
	stepCt=$stepCt+1
done
#

# 确认安装信息
echo "目标主路径："$dfDirName
stepCt=0
echo ""
for intItem in ${stepResult[*]}; do
	if [ $intItem == 1 ]; then
		echo -e ${steps[$stepCt]}"："\\u2714
	fi
	stepCt=$(($stepCt + 1))
done
#

# 执行安装
stepCt=0
# Step1：环境初始化
tipOpt ${steps[$stepCt]}

	# 1.1 创建主路径
if [ ! -d "/"$dfDirName ]; then
	mkdir -p -m 777 "/"$dfDirName"/data/cert"
	mkdir -p -m 777 "/"$dfDirName"/db_data/mysql"
	mkdir -p -m 777 "/"$dfDirName"/db_data/mongo"
	mkdir -p -m 777 "/"$dfDirName"/db_data/redis"
	mkdir -p -m 777 "/"$dfDirName"/logs/mysql"
	mkdir -p -m 777 "/"$dfDirName"/logs/mongo"
	mkdir -p -m 777 "/"$dfDirName"/logs/redis"
	mkdir -p -m 777 "/"$dfDirName"/node_pj"
	mkdir -p -m 777 "/"$dfDirName"/html/www"
fi
	#
tipFoot
#

# Step2： 安装Nginx
tipOpt ${steps[$stepCt]}
cat >> /etc/yum.repos.d/nginx.repo <<EOF
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF

sudo yum-config-manager --enable nginx-mainline
sudo dnf install -y nginx-1.17.1
cp -rf /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak
svrRoot="/"$dfDirName"/html/www;"
sed -i "s#/usr/share/nginx/html;#$svrRoot#" /etc/nginx/conf.d/default.conf

echo '启动Nginx服务'
echo 'Start the Nginx service'
systemctl restart nginx.service
systemctl enable nginx.service
curl 127.0.0.1

echo '==========================='
echo '              Nginx 版本'
nginx -v
echo '==========================='
tipFoot
#

# Step3： 安装Mysql
tipOpt ${steps[$stepCt]}
# 在线安装mysql8，@mysql模块将安装MySQL及其所有依赖项
sudo dnf install -y @mysql

cp /etc/my.cnf /etc/my.cnf.back
sed -i "s#datadir=/.*#datadir=/$dfDirName/db_data/mysql#" /etc/my.cnf
sed -i "s#socket=/.*#socket=/$dfDirName/db_data/mysql/mysql.sock#" /etc/my.cnf

echo -e "\n\
[client]\n\
default-character-set=utf8\n\
socket=/$dfDirName/db_data/mysql/mysql.sock\n\
\n\
[mysql]\n\
default-character-set=utf8\n\
socket=/$dfDirName/db_data/mysql/mysql.sock" >>/etc/my.cnf

echo '启动Mysql服务'
systemctl enable mysqld.service
systemctl restart mysqld.service

echo '==========================='
echo '              Mysql 版本'
mysql --help | grep Distrib
rpm -qa | grep mysql
systemctl status mysqld
echo '==========================='
tipFoot
#

# Step4： 安装PostgreSql
tipOpt ${steps[$stepCt]}
# Install the repository RPM:
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm

# Disable the built-in PostgreSQL module:
sudo dnf -qy module disable postgresql

# Install PostgreSQL:
sudo dnf install -y postgresql13-server

# Optionally initialize the database and enable automatic start:
/usr/pgsql-13/bin/postgresql-13-setup initdb

# 修改配置文件允许授信登录以便后续更改
sudo sed -i.bak \
-e 's|^local   all             all                                     peer|local   all             all                                     trust|' \
/var/lib/pgsql/13/data/pg_hba.conf

systemctl restart postgresql-13

systemctl enable postgresql-13
systemctl start postgresql-13

echo '==========================='
echo '              PostgreSql 版本'
rpm -qa | grep postgresql
systemctl status postgresql-13
echo '==========================='
tipFoot
#

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
#

# 环境清理
echo '环境清理'
sudo dnf clean all
echo '删除无用孤立的软件包'
sudo dnf -y autoremove
# 根文件夹授权
chmod -R 777 "/"$dfDirName
# 关闭 dnf-makecache 的定时器
echo '关闭 dnf-makecache 的定时器'
systemctl stop dnf-makecache.timer
systemctl disable dnf-makecache.timer


# 执行数据库初始化脚本
./initSql.sh >> initSqlLog
# MySql 账号和远程用户权限初始化脚本
# PostgreSql 账号和远程用户权限初始化脚本

# 公网开放 PostgeSql 访问权限
# 执行脚本
sudo sed -i.bak \
-e 's|^local   all             all                                     trust|local   all             all                                     md5|' \
-e 's|^local   replication     all                                     peer|local   replication     all                                     md5|' \
/var/lib/pgsql/13/data/pg_hba.conf

echo "host    all             all             0.0.0.0/0               md5" >> /var/lib/pgsql/13/data/pg_hba.conf

sudo sed -i.bak \
-e "s|^#listen_addresses = 'localhost'|listen_addresses = '\*'|" \
/var/lib/pgsql/13/data/postgresql.conf
systemctl restart postgresql-13

for item in ${steps[*]}; do
	stepResult[$stepCt]=1
	ckPort "${ports[$stepCt]}"
	stepCt=$stepCt+1
done

echo ""
echo ""
tipFirst "安装完成"
# 显示安装报告
tipGreen "=============================================================================="
tipGreen "·                                                                            ·"
tipGreen "·                                安 装 报 告                                 ·"
tipGreen "·                                                                            ·"
tipGreen "=============================================================================="
echo ""
getLine
tipGreen 数据库初始化
cat ./initSqlLog
echo ""
echo ""
getLine
tipGreen 端口
portAll=`firewall-cmd --zone=public --list-ports`
tipGreen $portAll
echo ""
echo ""
getLine
tipGreen NGINX 服务状态
systemctl status nginx
getLine
tipGreen MySql 服务状态
systemctl status mysqld
getLine
tipGreen PostgeSql 服务状态
systemctl status postgresql-13

echo ""
echo ""
getLine
tipGreen 版本号
nginx -v
rpm -qa | grep mysql
rpm -qa | grep postgresql
tipOpt "node 版本重启后，node -v 查看"
tipOpt "npm 版本重启后，npm -v 查看"
getLine
# 输出 SMPOO_LOGO
tipFinish
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""