#!/usr/bin/expect -f

set timeout 3
set dbPwdRoot "Smpoo@2015"
set dbPwdDev "Dev@2015"
set dbPwdProd "SmpooProd@2021"
# set tblName "mysql"
# 修改 root 密码
set strChangeRootPwd "ALTER user 'root'@'localhost' IDENTIFIED BY '$dbPwdRoot';\r"
# 授权 root 远程登录
set strClearRootPwd "UPDATE mysql.user SET host='%' WHERE user='root';\r"
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

spawn mysql -uroot -h 127.0.0.1 -p
expect {
"password:" {send "\r"};
}
expect {
"mysql>" {send "USE mysql;\r"};
}
expect {
"mysql>" {send $strChangeRootPwd};
}
expect {
"mysql>" {send $strClearRootPwd};
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
