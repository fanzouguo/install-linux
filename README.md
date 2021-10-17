# install-linux
The unmanned watching shell script for fast install the linux server.

# 注意

为避免网络原因导致 raw.githubusercontent 访问失败，可以事先添加以下 host 解析记录
``` shell
echo "185.199.108.133 raw.githubusercontent.com" >> /etc/hosts
echo "185.199.109.133 raw.githubusercontent.com" >> /etc/hosts
echo "185.199.110.133 raw.githubusercontent.com" >> /etc/hosts
echo "185.199.111.133 raw.githubusercontent.com" >> /etc/hosts
```

> !以上 ip 地址解析于 https://githubusercontent.com.ipaddress.com/raw.githubusercontent.com ,请注意 IP 地址变动

# 用例

> 初始化 Linux 服务器
``` shell
curl https://raw.githubusercontent.com/fanzouguo/install-linux/main/install.sh | bash
# 若因防火墙原因无法访问，则改为
curl -o-  https://cdn.jsdelivr.net/gh/fanzouguo/install-linux@main/install.sh | bash
wget -qO- https://cdn.jsdelivr.net/gh/fanzouguo/install-linux@main/install.sh | bash
git clone git@github.com:fanzouguo/install-linux.git ~/initSvr

# 若因版本缓存问题导致下载到了旧版，可改用
curl -o-  https://cdn.jsdelivr.net/gh/fanzouguo/install-linux@仓库最新版本号/install.sh | bash
```

> 安装 Nodejs - 10<v10.16.1>（ For Haya - tFrameV8 ）

注：不采用 nvm 的原因有以下两点：

1. 客户化的服务端部署成功后，不存在版本更新的情况（至少在 tFrame 平台机制下）
2. 由于防火墙的原因，通过 raw.githubusercontent.com 的 nvm 安装脚本可能会访问异常，导致 svrInit 脚本执行不成功
``` shell
# https://raw.githubusercontent.com/fanzouguo/install-linux/main/lib/initNodeJs.v10.sh
```

> 安装 Nodejs - 14<v14.17.6>（ For - tFrameV9 ）
``` shell
# https://raw.githubusercontent.com/fanzouguo/install-linux/main/lib/initNodeJs.v14.sh
```

> 备份 Linux 服务器（ For Haya - tFrameV8 ）
``` shell
# curl -o- https://raw.githubusercontent.com/fanzouguo/install-linux/main/lib/initBackup.sh | bash

# 或者单步依次执行下列命令

# wget -qO- https://raw.githubusercontent.com/fanzouguo/install-linux/main/lib/svrBack.sh | bash
```
