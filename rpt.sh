#!/bin/sh

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
echo  -e "\e[0;32;1m `firewall-cmd --zone=public --list-ports` \e[0m"
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
node -v
npm -v
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