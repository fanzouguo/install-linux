# 安装 certbot 组件，并实现自动续期
# 参考：
# 1、https://cloud.tencent.com/developer/article/1626782
# 2、https://certbot.eff.org/lets-encrypt/centosrhel8-nginx
# 3、https://certbot.eff.org/docs/install.html#certbot-auto
# 4、https://www.iplayio.cn/post/966860296
sudo openssl dhparam -out /smpoo_file/data/cert/dhparam.pem 2048
sudo dnf install -y mod_ssl snapd
# python3-certbot-nginx
systemctl enable --now snapd.socket
sudo ln -s /var/lib/snapd/snap /snap
sudo snap install core;
sudo snap refresh core
sudo dnf remove -y certbot
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo certbot --nginx