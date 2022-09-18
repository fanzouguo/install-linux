# install-linux
tFrame工程脚本集合

# 用例

> 初始化 Linux 服务器
```shell
curl https://raw.githubusercontent.com/fanzouguo/install-linux/main/script/install.sh | bash
```
# 若因防火墙原因无法访问，则改为

```shell
curl -o-  https://cdn.jsdelivr.net/gh/fanzouguo/install-linux@main/script/install.sh | bash

# OR

wget -qO- https://cdn.jsdelivr.net/gh/fanzouguo/install-linux@main/script/install.sh | bash

# OR

git clone git@github.com:fanzouguo/install-linux.git ~/initSvr
```

# 若因版本缓存问题导致下载到了旧版，可改用
```shell
curl -o-  https://cdn.jsdelivr.net/gh/fanzouguo/install-linux@仓库最新版本号/install.sh | bash
```

# 注意

为避免网络原因导致 raw.githubusercontent 访问失败，可以事先添加以下 host 解析记录
``` shell
echo "185.199.108.133 raw.githubusercontent.com" >> /etc/hosts
echo "185.199.109.133 raw.githubusercontent.com" >> /etc/hosts
echo "185.199.110.133 raw.githubusercontent.com" >> /etc/hosts
echo "185.199.111.133 raw.githubusercontent.com" >> /etc/hosts
```

> !以上 ip 地址解析于 https://githubusercontent.com.ipaddress.com/raw.githubusercontent.com ,请注意 IP 地址变动
