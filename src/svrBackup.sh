#! /bin/bash
cd ~
mkdir -p /smpoo_file/data/back/html/nginx/www
mkdir -p /smpoo_file/data/back/etc/nginx/conf.d
mkdir -p /smpoo_file/data/back/node_pj

cp -rf /smpoo_file/html/nginx/www/static /smpoo_file/data/back/html/nginx/www
cp -rf /smpoo_file/html/nginx/www/app /smpoo_file/data/back/html/nginx/www
cp -rf /etc/nginx/conf.d/default.conf /smpoo_file/data/back/etc/nginx/conf.d/
cp -rf /smpoo_file/node_pj/package.json /smpoo_file/data/back/node_pj/

function backPj() {
  echo "准备备份项目服务端配置，请输入项目名称："
  read -p ""  pjname
  if [ ! -n "$pjname" ]; then
    echo "项目名称不能为空"
    backPj
  else
    echo "准备备份"$pjname"项目下的 sys_conf"
    mkdir -p "/smpoo_file/data/back/node_pj/"$pjname
		cp -rf "/smpoo_file/node_pj/"$pjname"/sys_conf" "/smpoo_file/data/back/node_pj/"$pjname"/sys_conf"
		cp -rf "/smpoo_file/node_pj/"$pjname "/smpoo_file/data/back/node_pj/"$pjname
		rm -rf "/smpoo_file/node_pj/"$pjname"/log"
  fi
}
