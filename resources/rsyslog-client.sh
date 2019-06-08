#!/bin/bash

###setting up machine to run as rsyslog client to server rsyslog
rsyslog_server="testingrsyslog"
rsyslog_ip=$(gcloud compute instances list | grep $rsyslog_server | awk '{ print $4 }' | tail -1)

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
