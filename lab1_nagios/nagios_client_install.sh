#!/bin/bash
# make sure that instance is on Allow full access to all Cloud APIs

# configuration for web-a
######################
#   On the client   #
######################

#####INSTALL APACHE#####
yum -y install httpd
systemctl enable httpd
systemctl start httpd

#####INSTALL PLUG-INS#####
yum -y install nagios-nrpe-server nagios-plugins nagios-plugins-load nagios-plugins-ping nagios-plugins-disk nagios-plugins-http nagios-plugins-procs nagios-plugins-users

#####NRPE INSTALLATION#####
yum -y install nrpe
systemctl enable nrpe
systemctl start nrpe


#####MISC SYSTEM METRICS#####
#command[check_users]=/usr/lib64/nagios/plugins/check_users $ARG1$
#command[check_load]=/usr/lib64/nagios/plugins/check_load $ARG1$
#command[check_disk]=/usr/lib64/nagios/plugins/check_disk $ARG1$
#command[check_swap]=/usr/lib64/nagios/plugins/check_swap $ARG1$
#command[check_cpu_stats]=/usr/lib64/nagios/plugins/check_cpu_stats.sh $ARG1$

#####MISC SYSTEM METRICS#####
command[check_users]=/usr/lib64/nagios/plugins/check_users -w 5 -c 10
command[check_load]=/usr/lib64/nagios/plugins/check_load -w 15,10,5 -c 30,25,20
command[check_disk]=/usr/lib64/nagios/plugins/check_disk -w 20% -c 10%
command[check_swap]=/usr/lib64/nagios/plugins/check_swap -w 20% -c 10%
command[check_cpu_stats]=/usr/lib64/nagios/plugins/check_cpu_stats.sh -w 70,40,30 -c 90,50,40

#####SERVER NAME#####
nagios_server="nagios-a"
#####INTERNAL IP#####
nagios_ip=$(gcloud compute instances list | grep $nagios_server | awk '{ print $4 }' | tail -1)

#####ALLOW NAGIOS SERVER#####
sed -i 's/allowed_hosts=127.0.0.1/allowed_hosts=127.0.0.1, '$nagios_ip'/g' /etc/nagios/nrpe.cfg

systemctl restart nrpe
