# install-linux
The unmanned watching shell script for fast install the linux server.

# 注意

为避免网络原因导致 raw.aaaa 访问失败，可以事先添加以下 host 解析记录
```
echo "185.199.108.133 raw.githubusercontent.com" >> /etc/hosts
echo "185.199.109.133 raw.githubusercontent.com" >> /etc/hosts
echo "185.199.110.133 raw.githubusercontent.com" >> /etc/hosts
echo "185.199.111.133 raw.githubusercontent.com" >> /etc/hosts
```

> !以上 ip 地址解析于 https://githubusercontent.com.ipaddress.com/raw.githubusercontent.com ,请注意 IP 地址变动

# 用例

> 初始化 Linux 服务器
```
curl https://raw.githubusercontent.com/fanzouguo/install-linux/main/src/install.sh | bash
```

> 安装 Nodejs - 10<v10.16.1>（ For Haya - tFrameV8 ）
```
https://raw.githubusercontent.com/fanzouguo/install-linux/main/src/initNodeJs.v10.sh
```

> 安装 Nodejs - 14<v14.17.6>（ For - tFrameV9 ）
```
https://raw.githubusercontent.com/fanzouguo/install-linux/main/src/initNodeJs.v14.sh
```

> 备份 Linux 服务器（ For Haya - tFrameV8 ）
```
curl https://raw.githubusercontent.com/fanzouguo/install-linux/main/src/svrBackup.sh | bash
```
