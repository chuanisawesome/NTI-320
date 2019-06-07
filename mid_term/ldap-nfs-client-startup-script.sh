#!/usr/bin/env bash

# updates system APT database
apt-get update

export DEBIAN_FRONTEND=noninteractive

# Installs debconf
apt-get --yes install libnss-ldap libpam-ldap ldap-utils nscd

# echo ldap tempfile
echo "ldap-auth-config ldap-auth-config/bindpw password
nslcd nslcd/ldap-bindpw password
ldap-auth-config ldap-auth-config/rootbindpw password
ldap-auth-config ldap-auth-config/move-to-debconf boolean true
nslcd nslcd/ldap-sasl-krb5-ccname string /var/run/nslcd/nslcd.tkt
nslcd nslcd/ldap-starttls boolean false
libpam-runtime libpam-runtime/profiles multiselect unix, ldap, systemd, capability
nslcd nslcd/ldap-sasl-authzid string
ldap-auth-config ldap-auth-config/rootbinddn string cn=ldapadm,dc=nti310,dc=local
nslcd nslcd/ldap-uris string ldap://ldap-d
nslcd nslcd/ldap-reqcert select
nslcd nslcd/ldap-sasl-secprops string
ldap-auth-config ldap-auth-config/ldapns/ldap_version select 3
ldap-auth-config ldap-auth-config/binddn string cn=proxyuser,dc=example,dc=net
nslcd nslcd/ldap-auth-type select none
nslcd nslcd/ldap-cacertfile string /etc/ssl/certs/ca-certificates.crt
nslcd nslcd/ldap-sasl-realm string
ldap-auth-config ldap-auth-config/dbrootlogin boolean true
ldap-auth-config ldap-auth-config/override boolean true
nslcd nslcd/ldap-base string dc=nti310,dc=local
ldap-auth-config ldap-auth-config/pam_password select md5
nslcd nslcd/ldap-sasl-mech select
nslcd nslcd/ldap-sasl-authcid string
ldap-auth-config ldap-auth-config/ldapns/base-dn string dc=nti310,dc=local
ldap-auth-config ldap-auth-config/ldapns/ldap-server string ldap://ldap-d/
nslcd nslcd/ldap-binddn string
ldap-auth-config ldap-auth-config/dblogin boolean false" >> tempfile

while read line; do echo "$line" | debconf-set-selections; done < tempfile

echo "$secretpasswd" > /etc/ldap.secret
sudo auth-client-config -t nss -p lac_ldap

echo "account sufficient pam_succeed_if.so uid = 0 use_uid quiet" >> /etc/pam.d/su
sed -i 's/base dc=example,dc=net/base dc=nti310,dc=local/g' /etc/ldap.conf
sed -i 's,uri ldapi:///,uri ldap://ldap-d/,g' /etc/ldap.conf
sed -i 's/rootbinddn cn=manager,dc=example,dc=net/rootbinddn cn=ldapadm,dc=nti310,dc=local/g' /etc/ldap.conf

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

###setting up machine to run as rsyslog client to server rsyslog

yum update -y && yum install -y rsyslog

systemctl enable rsyslog
systemctl start rsyslog

#on the rsyslog client
#add to end of file
#internal ip
echo "*.* @@$rsys_ip:514" >> /etc/rsyslog.conf

systemctl restart rsyslog

##check to see if rsyslog is active
systemctl status rsyslog
