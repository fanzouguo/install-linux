#!/bin/sh
source ./getRoot.sh

# 项目根路径
ROOT_PATH=`getRoot`
# 脚本执行日期
EXEC_DATE=$(date "+%Y-%m-%d %H:%M:%S")
# 本机内网IP地址
ipStr=$(/sbin/ifconfig -a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | tr -d "addr:")

# 检查 WSL 服务器是否已完成初始化
function checkDone() {
	checkFile=""
	if [ "$1" == "alpine" ]; then
		checkFile=$ROOT_PATH/.alpineDone
	elif [ "$1" == "ubuntu" ]; then
		checkFile=$ROOT_PATH/.ubuntuDone
	fi

	if [ ! -n "$checkFile" ]; then
		echo "y"
	else
		if [ -e $checkFile ]; then
			echo "y"
		else
			echo "n"
		fi
	fi
}
# 设置 WSL 服务器为已初始化状态
function setDone() {
	showSucc "安装已全部完成!"

	checkFile=""
	if [ "$1" == "alpine" ]; then
		checkFile=$ROOT_PATH/.alpineDone
	elif [ "$1" == "ubuntu" ]; then
		checkFile=$ROOT_PATH/.ubuntuDone
	fi

	if [ -n "$checkFile" ]; then
		echo "$EXEC_DATE 执行服务器初始化" >> $checkFile
		chmod 444 $checkFile
	fi

	echo ""
}

# region 控制台函数库
# 打印宿主机系统信息
function showSysInfo() {
	showErr "=============================================================================="
	showErr "·                                                                            ·"
	showErr "·                      This scricpt is base on:                              ·"
	showErr "·                                W S L                                       ·"
	showErr "·                                                                            ·"
	showErr "=============================================================================="
	osName=`uname -a`
	echo ""
	echo ""
	echo  -e "\e[44;37;1m WSL内核: \e[0m"
	echo `cat /proc/version`
	echo ""
	echo 系统版本号：$1
	echo 服务器日期：$EXEC_DATE
	echo 服务器 IP ：$ipStr
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
# 信息提示类-蓝色
function showInfo() {
	echo -e $2"\e[0;34;1m $1 \e[0m"
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
