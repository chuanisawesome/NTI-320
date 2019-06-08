#!/bin/bash

#####INSTALL APACHE#####
yum -y install httpd
systemctl enable httpd
systemctl start httpd

# Install snmp and tools
yum -y install net-snmp net-snmp-utils

# create a new snmpd.conf
mv /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.orig
touch /etc/snmp/snmpd.conf

# edit snmpd.conf file /etc/snmp/snmpd.conf
echo '# create myuser in mygroup authenticating with 'public' community string and source network 10.138.0.0/24
com2sec myUser 10.138.0.0/24 public

# myUser is added into the group 'myGroup' and the permission of the group is defined
group    myGroup    v1        myUser
group    myGroup    v2c        myUser
view all included .1
access myGroup    ""    any    noauth     exact    all    all    none' >> /etc/snmp/snmpd.conf

# Enable snmp, Start snmp
systemctl enable snmpd
systemctl start snmpd

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
