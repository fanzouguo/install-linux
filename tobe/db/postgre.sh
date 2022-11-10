#!/usr/bin/expect -f

set timeout 3
set dbPwdSuper "Smpoo@2015"
set dbPwdRoot "Root@2015"
set dbPwdDev "Dev@2015"
set dbPwdProd "SmpooProd@2021"
set tblName "mysql"

set strChangePwdRoot "ALTER USER postgres WITH PASSWORD '$dbPwdSuper';\r"
set strRootUser "CREATE USER root WITH PASSWORD '$dbPwdDev';\r"
set strDevUser "CREATE USER dev WITH PASSWORD '$dbPwdDev';\r"
set strProdUser "CREATE USER prod WITH PASSWORD '$dbPwdProd';\r"

spawn psql -U postgres
expect {
"postgres=#" {send $strChangePwdRoot};
}
expect {
"postgres=#" {send $strRootUser};
}
expect {
"postgres=#" {send $strDevUser};
}
expect {
"postgres=#" {send $strProdUser};
}
expect {
"postgres=#" {send "\\q\r"};
}
interact


# sudo sed -i.bak \
# -e 's|^local   all             all                                     trust|local   all             all                                     md5|' \
# -e 's|^local   replication     all                                     peer|local   replication     all                                     md5|' \
# /var/lib/pgsql/13/data/pg_hba.conf
# echo "host    all             all             0.0.0.0/0               md5" >> /var/lib/pgsql/13/data/pg_hba.conf
# systemctl restart postgresql-13
# echo 'Done!'