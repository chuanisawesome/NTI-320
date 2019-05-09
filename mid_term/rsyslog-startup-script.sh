#!/bin/bash

#purpose: central location for server information/logs

yum update -y
yum install -y rsyslog
yum install -y net-tools

systemctl start rsyslog
systemctl enable rsyslog

#To configure rsyslog as a network/central logging server, 
#you need to set the protocol (either UDP or TCP or both) it 
#will use for remote syslog reception as well as the port it listens on.
sed -i 's/#$ModLoad imudp/$ModLoad imudp/g' /etc/rsyslog.conf
sed -i 's/#$ModLoad imtcp/$ModLoad imtcp/g' /etc/rsyslog.conf
sed -i 's/#$InputTCPServerRun 514/$InputTCPServerRun 514/g' /etc/rsyslog.conf
sed -i 's/#$UDPServerRun 514/$UDPServerRun 514/g' /etc/rsyslog.conf

systemctl restart rsyslog

netstat -antup | grep 514
