#!/bin/sh
source ./getRoot.sh
source ./base.sh

ROOT_PATH=`getRoot`

# 初始化全局目录
function initFolder() {
	showInfo "初始化全局目录"...

	# mkdir -p $ROOT_PATH

	dbTypes1="mongo"
	dbTypes2="mysql"
	dbTypes3="postgres"
	dbTypes4="redis"
	dbTypes5="meilisearch"
	dbTypes6="minio"

	toolsType1=codeServer
	toolsType2=firefoxSend
	toolsType3=frp
	toolsType4=gitLab
	toolsType5=noVnc
	toolsType6=svn
	toolsType7=verdaccio

	# 在首次初始化时初始化根目录
	mkdir -pv $ROOT_PATH/.env/nginx/cert
	mkdir -pv $ROOT_PATH/.env/nginx/conf
	mkdir -pv $ROOT_PATH/.env/nginx/_letsencrypt
	mkdir -pv $ROOT_PATH/.env/db
	mkdir -pv $ROOT_PATH/.env/nodeGlobal
	mkdir -pv $ROOT_PATH/.env/svn/repo

	mkdir -pv $ROOT_PATH/docker

	mkdir -pv $ROOT_PATH/logs/nginx
	mkdir -pv $ROOT_PATH/logs/db

	mkdir -pv $ROOT_PATH/backup/nginx
	mkdir -pv $ROOT_PATH/backup/db

	mkdir -pv $ROOT_PATH/common/.smpoo
	mkdir -pv $ROOT_PATH/project
	mkdir -pv $ROOT_PATH/scricpt
	mkdir -pv $ROOT_PATH/tools

	# DB
	for dbItem in $dbTypes1 $dbTypes2 $dbTypes3 $dbTypes4 $dbTypes5 $dbTypes6;
	do
		mkdir -pv $ROOT_PATH/.env/db/$dbItem/conf
		mkdir -pv $ROOT_PATH/.env/db/$dbItem/data
	done

	# Tools
	for toolsTypeItem in $toolsType1 $toolsType2 $toolsType3 $toolsType4 $toolsType5 $toolsType6 $toolsType7;
	do
		mkdir -pv $ROOT_PATH/.env/$toolsTypeItem/conf
		mkdir -pv $ROOT_PATH/.env/$toolsTypeItem/data
	done

	# nodeJs 全局
	nodeVers1=haya
	nodeVers2=tmind
	nodeVers3=tcoffe
	for nodeVersItem in $nodeVers1 $nodeVers2 $nodeVers3;
	do
		mkdir -pv $ROOT_PATH/.env/nodeGlobal/$nodeVersItem/npmRepo/cache
		mkdir -pv $ROOT_PATH/.env/nodeGlobal/$nodeVersItem/npmRepo/global

		mkdir -pv $ROOT_PATH/.env/nodeGlobal/$nodeVersItem/pnpmRepo/.store
		mkdir -pv $ROOT_PATH/.env/nodeGlobal/$nodeVersItem/pnpmRepo/cache
		mkdir -pv $ROOT_PATH/.env/nodeGlobal/$nodeVersItem/pnpmRepo/global

		mkdir -pv $ROOT_PATH/.env/nodeGlobal/$nodeVersItem/yarnRepo/cache
		mkdir -pv $ROOT_PATH/.env/nodeGlobal/$nodeVersItem/yarnRepo/global
		mkdir -pv $ROOT_PATH/.env/nodeGlobal/$nodeVersItem/yarnRepo/link
		mkdir -pv $ROOT_PATH/.env/nodeGlobal/$nodeVersItem/yarnRepo/offline
	done

	# 日志
	mkdir -pv nginx
	for dbItem in $dbTypes1 $dbTypes2 $dbTypes3 $dbTypes4 $dbTypes5 $dbTypes6;
	do
		mkdir -pv $ROOT_PATH/logs/db/$dbItem
	done

	# 备份
	mkdir -pv nginx
	for dbItem in $dbTypes1 $dbTypes2 $dbTypes3 $dbTypes4 $dbTypes5 $dbTypes6;
	do
		mkdir -pv $ROOT_PATH/backup/db/$dbItem
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

	createProjectFolder tcoffe
}
# 创建项目目录
function createProjectFolder() {
	PROJECT_NAME=$1

	if [ ! -n "$PROJECT_NAME" ]; then
		echo ""
		read -p $'请输入新的工程名称：\x0a' newPjName
		if [ ! -n "$newPjName" ]; then
			showErr "必须输入新的工程名称"
			exit 0
		else
			PROJECT_NAME="$newPjName"
		fi
	fi

	echo ""
	echo ""

	mkdir -pv $ROOT_PATH/logs/$PROJECT_NAME $ROOT_PATH/backup/$PROJECT_NAME

	mkdir -pv $ROOT_PATH/project/$PROJECT_NAME/data
	mkdir -pv $ROOT_PATH/project/$PROJECT_NAME/dockerFile
	mkdir -pv $ROOT_PATH/project/$PROJECT_NAME/html/docs
	mkdir -pv $ROOT_PATH/project/$PROJECT_NAME/html/files
	mkdir -pv $ROOT_PATH/project/$PROJECT_NAME/html/www

	mkdir -pv $ROOT_PATH/project/$PROJECT_NAME/nodePj/node_modules
	mkdir -pv $ROOT_PATH/project/$PROJECT_NAME/nodePj/space
	mkdir -pv $ROOT_PATH/project/$PROJECT_NAME/scricpt

	stepDone "目录结构初始化"
}