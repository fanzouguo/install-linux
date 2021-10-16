#!/bin/sh

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

sudo dnf clean metadata
sudo dnf clean all
sudo dnf makecache
sudo dnf update -y
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

echo "1、init the Environmental | 2、install Nginx | 3、install Mysql | 4、install PostgreSql | 5、install NodeJs"

steps=("Env_init" "install_Nginx" "install_Mysql" "install_PostgreSql" "install_NodeJs")
ports=("-1" "80" "3306" "5432" "-1")
# 步骤选择结果
stepResult=(0 0 0 0 0)
unInstall=""

# 全局参数
# 默认主路径
dfDirName="smpoo_file"
# 步骤计数器
stepCt=0
# mysql 默认root密码
dbPwdRoot="Smpoo@2015"
dbPwdDev="Dev_2015"
# NodeJs 版本
VER_NUM="v14.15.4"
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
			echo "the port [ $subItem ] will be auto allow!"
			firewall-cmd --permanent "--add-port=$subItem/tcp"
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
# 步骤结束提示
function tipFoot() {
	# 输入100个等号
	showStr=$(printf '%100s\n' | tr ' ' =)
	echo $showStr${steps[$stepCt]}"完成..."
	echo $showStr${steps[$stepCt]}" done..."
	stepCt=$(($stepCt + 1))
}
#

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
echo "Target folder is "$dfDirName
stepCt=0
echo ""
echo ""
for intItem in ${stepResult[*]}; do
	if [ $intItem == 1 ]; then
		echo -e ${steps[$stepCt]}"："\\u2714
	fi
	stepCt=$(($stepCt + 1))
done
echo "========================"
echo "已被忽略的安装项"
echo "The skipped installation item is:"
echo $unInstall

echo -e "\e[44;37;1m 以上信息是否正确？ Yes(y) | No(n) \e[0m"
echo -e "\e[44;37;1m Are you sure this is all correct ? Yes(y) | No(n) \e[0m"
read -p "" isRight
case $isRight in
y) ;;

n)
	exit 1
	;;
*) ;;

esac
#

# 执行安装
echo ""

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
sudo dnf install nginx-1.17.1
cp /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak
svrRoot="/"$dfDirName"/html/www;"
sed -i "s#/usr/share/nginx/html;#$svrRoot#" /etc/nginx/conf.d/default.conf

echo '启动Nginx服务'
echo 'Start the Nginx service'
systemctl restart nginx.service
systemctl enable nginx.service
curl 127.0.0.1

echo '==========================='
echo '              Nginx 版本'
echo '              Nginx Ver'
nginx -v
echo '==========================='
tipFoot
#

