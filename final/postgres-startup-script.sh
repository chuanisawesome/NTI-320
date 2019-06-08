#!/usr/bin/env bash

# install the EPEL repository, that contains extra packages that we need
yum install epel-release -y
# install the components we need for postgres
yum install python-pip python-devel gcc postgresql-server postgresql-devel postgresql-contrib -y
# initialize the PostgreSQL database
postgresql-setup initdb

# enable and start postgresql
systemctl enable postgresql
systemctl start postgresql

# backs up the pg_hba.conf file and find and replace
sed -i.bak 's/ident/md5/g' /var/lib/pgsql/data/pg_hba.conf

# restarts and enable postgresql
systemctl restart postgresql
systemctl enable postgresql

# echo creating a database into a sql file
echo "CREATE DATABASE myproject;
CREATE USER myprojectuser WITH PASSWORD 'password';
ALTER ROLE myprojectuser SET client_encoding TO 'utf8';
ALTER ROLE myprojectuser SET default_transaction_isolation TO 'read committed';
ALTER ROLE myprojectuser SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE myproject TO myprojectuser;" > /tmp/sqlfile.sql
# runs the sql code in sqlfile as the postgres user
sudo -i -u postgres psql -U postgres -f /tmp/sqlfile.sql

systemctl restart postgresql.service

# check the status: active or not
systemctl status postgresql

#--------------Install the phpPgAdmin software-------------

# install gui for phpadmin
yum install phpPgAdmin -y

# allow access granted 
sed -i.bak -e 's/Require local/ Require all granted/g' -e 's/Allow from 127.0.0.1/ Allow from all/g' /etc/httpd/conf.d/phpPgAdmin.conf

# enable and start apache
systemctl enable httpd
systemctl start httpd

# change password
sudo -i -u postgres psql -U postgres -d template1 -c "ALTER USER postgres WITH PASSWORD 'postgres';"

# change security so that usernames such as postgres will have access
sed -i "s,\$conf\['extra_login_security'\] = true;,\$conf\['extra_login_security'\] = false;,g" /etc/phpPgAdmin/config.inc.php

systemctl restart postgresql.service

# change local peer to md5
sed -i.bak 's/peer/md5/g' /var/lib/pgsql/data/pg_hba.conf

# restart postgres and apache
systemctl restart postgresql.service
systemctl reload httpd

# adds host all at the end of the line
echo 'host    all             all             10.138.0.0/20            md5' >> /var/lib/pgsql/data/pg_hba.conf

# able to listen to all addr
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /var/lib/pgsql/data/postgresql.conf

systemctl restart postgresql.service
systemctl reload httpd

#enforcing to permissive
setenforce 0

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
