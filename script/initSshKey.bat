SET REMOTEHOST=root@远程目标IP

scp %UserProfile%/.ssh/id_rsa.pub %REMOTEHOST%:~/.ssh/
ssh %REMOTEHOST% "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys && rm -rf ~/.ssh/id_rsa.pub"