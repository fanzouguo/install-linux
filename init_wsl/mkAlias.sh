#!/bin/sh

function mkClear() {
	echo -e "" >> /root/.clear.sh
	chmod 755 /root/.clear.sh
	cat >> /root/.clear.sh <<- EOF
		#!/bin/sh

		clear
		echo -e "\e[0;31;1m 已进入WSL... \e[0m"
	EOF
	chmod 755 /root/.clear.sh
	chmod +x /root/.clear.sh
}