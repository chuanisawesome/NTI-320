#!/bin/bash

# Installes a number of packages, including mariadb, httpd, php and so on
yum -y install cacti
yum -y install mariadb-server
yum -y install php-process php-gd php


 # Enable db, apache and snmp (not cacti yet)
systemctl enable mariadb && systemctl start mariadb
systemctl enable httpd && systemctl start httpd
systemctl enable snmpd && systemctl start snmpd

# Set your mysql/mariadb pasword 
db_password="P@ssw0rd1"
cacti_password="P@ssw0rd1"

 # Make a sql script to create a cacti db and grant the cacti user access to it
mysqladmin -u root password $db_password

# add tzinfo to mysql db
mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root -p"$db_password" mysql

# insert this sql into the db
echo "create database cacti;
GRANT ALL ON cacti.* TO cacti@localhost IDENTIFIED BY '$cacti_password';
FLUSH privileges;

GRANT SELECT ON mysql.time_zone_name TO cacti@localhost;
flush privileges;" > stuff.sql

# Run sql script
mysql -p"$db_password" -u root < stuff.sql

# grabs the path to cacti
mypath=$(rpm -ql cacti|grep cacti.sql)
mysql cacti < $mypath -u cacti -p"$cacti_password"

# Modify cacti credencials to use user cacti & Password
sed -i.bak "s,\$database_username = 'cactiuser',\$database_username = 'cacti',g" /etc/cacti/db.php
sed -i "s,\$database_password = 'cactiuser',\$database_password = '$cacti_password',g" /etc/cacti/db.php

# Open up apache to configure
sed -i 's/Require host localhost/Require all granted/' /etc/httpd/conf.d/cacti.conf
sed -i 's/Allow from localhost/Allow from all all/' /etc/httpd/conf.d/cacti.conf

# Fix the php.ini script
cp /etc/php.ini /etc/php.ini.orig
sed -i 's/;date.timezone =/date.timezone = America\/Regina/' /etc/php.ini

systemctl restart httpd.service

# Set up the cacti cron
sed -i 's/#//g' /etc/cron.d/cacti

# don't load an selinux policy on next boot
sed -i 's,SELINUX=enforcing,SELINUX=disabled,g' /etc/sysconfig/selinux
setenforce 0
