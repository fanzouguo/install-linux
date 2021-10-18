#!/usr/bin/expect -f

set timeout 3
set dbPwdRoot "Smpoo@2015"
set dbPwdDev "Dev@2015"
set dbPwdProd "SmpooProd@2021"
# set tblName "mysql"
# 清除 root 密码并授权远程登录
set strClearRootPwd "UPDATE mysql.user SET host='%', authentication_string='' WHERE user='root';\r"
# 修改 root 密码
set strChangeRootPwd "ALTER user 'root'@'%' IDENTIFIED BY '$dbPwdRoot';\r"
# 创建 DEV 用户
set strUserDev "CREATE user 'dev'@'%' IDENTIFIED BY '$dbPwdDev';CREATE user 'prod'@'%' IDENTIFIED BY '$dbPwdProd';\r"
# 创建 prod 用户
set strUserProd "CREATE user 'prod'@'%' IDENTIFIED BY '$dbPwdProd';\r"
# 远程root用户授权
set strGrantRoot "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;FLUSH PRIVILEGES;\r"
# 远程 dev 用户授权
# set strGrantDev "GRANT ALL PRIVILEGES ON $tblName.* TO 'dev'@'%';FLUSH PRIVILEGES;\r"
# 远程 prod 用户授权
# set strGrantProd "GRANT ALL PRIVILEGES ON $tblName.* TO 'prod'@'%';FLUSH PRIVILEGES;\r"
set strEnd "SELECT host,user,authentication_string FROM mysql.user;\r"

# TODO: 修改 系统（非DB）的 dev 和 prod 密码
# passwd dbuser
# TODO: 切换到 postgres 账号下执行 postgresql相关的授权指令
# su postgres

# TODO:  执行完成后，等待用户输入 root 密码后，切换回 root 账号
# su root

# TODO: 继续显示 安装报告

spawn mysql -uroot -h 127.0.0.1 -p
expect {
"password:" {send "\r"};
}
expect {
"mysql>" {send "USE mysql;\r"};
}
expect {
"mysql>" {send $strClearRootPwd};
}
expect {
"mysql>" {send $strChangeRootPwd};
}
expect {
"mysql>" {send $strUserDev};
}
expect {
"mysql>" {send $strUserProd};
}
expect {
"mysql>" {send $strGrantRoot};
}
# expect {
# "mysql>" {send $strGrantDev};
# }
# expect {
# "mysql>" {send $strGrantProd};
# }
expect {
"mysql>" {send $strEnd};
}
expect {
"mysql>" {send "quit\r"};
}
interact