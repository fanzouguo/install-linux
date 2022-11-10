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

# -----------------------------------------------------------------------
# 切换到 mysql 库
set strChangeDb "user mysql;\r"
# 修改 root@% 和 root@localhost 密码
set strPwdRootAll "ALTER user 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'Smpoo@2015';\r"
set strPwdRootLocal "ALTER user 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'Smpoo@2015';\r"
# 取消密码过期
set strPwdExpireAll "ALTER user 'root'@'%' IDENTIFIED BY 'Smpoo@2015' PASSWORD expire never;\r"
set strPwdExpireLocal "ALTER user 'root'@'localhost' IDENTIFIED BY 'Smpoo@2015' PASSWORD expire never;\r"
# 创建用户
set strCreateDev "CREATE USER 'dev'@'%' IDENTIFIED BY 'Dev_2015';\r"
set strCreateProd "CREATE USER 'prod'@'%' IDENTIFIED BY 'SmpooProd@2015';\r"
# 内存刷新指令
set strReflush "FLUSH PRIVILEGES;\r"

spawn mysql -uroot -p123456
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
