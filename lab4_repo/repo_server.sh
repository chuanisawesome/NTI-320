#!/bin/bash

yum -y install createrepo
yum -y install httpd
yum -y install wget

mkdir -v -p /repos/centos/7/extras/x86_64/Packages/

# cp helloworld-0.1-1.el7.x86_64.rpm /repos/centos/7/extras/x86_64/Packages/

createrepo --update /repos/centos/7/extras/x86_64/Packages/

setenforce 0
systemctl enable httpd
systemctl start httpd

ln -s  /repos/centos /var/www/html/centos
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak

sed -i '144i     Options All' /etc/httpd/conf/httpd.conf
sed -i '145i    # Disable directory index so that it will index our repos' /etc/httpd/conf/httpd.conf
sed -i '146i     DirectoryIndex disabled' /etc/httpd/conf/httpd.conf
sed -i 's/^/#/' /etc/httpd/conf.d/welcome.conf

chown -R apache:apache /repos/
systemctl restart httpd