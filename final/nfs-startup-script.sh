#!/usr/bin/env bash

#install nfs utilities
yum install -y nfs-utils

#directories that is shared with client
mkdir /var/nfsshare
mkdir /var/nfsshare/devstuff
mkdir /var/nfsshare/testing
mkdir /var/nfsshare/home_dirs

#gives permission for testing
chmod -R 777 /var/nfsshare/

#enable and starts the nfs services
systemctl enable rpcbind
systemctl enable nfs-server
systemctl enable nfs-lock
systemctl enable nfs-idmap
systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap

#changes directory
cd /var/nfsshare/

#export NFS config files
echo "/var/nfsshare/home_dirs *(rw,sync,no_all_squash)
/var/nfsshare/devstuff  *(rw,sync,no_all_squash)
/var/nfsshare/testing   *(rw,sync,no_all_squash)" >> /etc/exports

#restart nfs-server because of the changes that has been made
systemctl restart nfs-server

#install net-tools to use the ifconfig command
yum -y install net-tools

#grabs the current internal ip that is needed for client install
ifconfig -a | awk 'NR==2{ sub(/^[^0-9]*/, "", $2); printf "This is your Ip Address: %s\n", $2; exit }'