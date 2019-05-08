#!/usr/bin/env bash

# updates system APT database
apt-get update

export DEBIAN_FRONTEND=noninteractive

# Installs debconf
apt-get -y install debconf-utils

# echo ldap debconf
echo -e "ldap-auth-config	ldap-auth-config/rootbindpw	password	
ldap-auth-config	ldap-auth-config/bindpw	password	
ldap-auth-config	ldap-auth-config/ldapns/ldap_version	select	3
ldap-auth-config	ldap-auth-config/pam_password	select	md5
ldap-auth-config	ldap-auth-config/binddn	string	cn=proxyuser,dc=example,dc=net
ldap-auth-config	ldap-auth-config/move-to-debconf	boolean	true
ldap-auth-config	ldap-auth-config/override	boolean	true
ldap-auth-config	ldap-auth-config/rootbinddn	string	cn=manager,dc=example,dc=net
ldap-auth-config	ldap-auth-config/ldapns/ldap-server	string	ldap://$ldap_ip
ldap-auth-config	ldap-auth-config/ldapns/base-dn	string	dc=nti310,dc=local
ldap-auth-config	ldap-auth-config/dblogin	boolean	false
ldap-auth-config	ldap-auth-config/dbrootlogin	boolean	false" > ldap_debconf

while read line; do echo "$line" | debconf-set-selections; done < ldap_debconf

# Installs ldap utils
apt-get -y install libpam-ldap nscd

# Set login to include ldap
sed -i 's/compat/compat ldap/g' /etc/nsswitch.conf
/etc/init.d/nscd restart

# test to see if ldap users outputs
getent passwd
export DEBIAN_FRONTEND=interactive

# -------------------- Start of NFS Client --------------------------

#install nfs client
apt-get install nfs-client -y

#input for the ipaddress that from nfs server
#nfs_ip=X.X.X.X
echo "This is the ip address you input: $nfs_ip"

#show available mounts on nfs server
showmount -e $nfs_ip

#makes a directory for testing
mkdir /mnt/test

#this will mount the shared fles on reboot
echo "$nfs_ip:/var/nfsshare/testing        /mnt/test       nfs     defaults 0 0" >> /etc/fstab

#mount all shares in the fstab file
mount -a

#change to testing directory
cd /mnt/test
