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
yum -y install nagios-nrpe-server nagios-plugins nagios-plugins-load nagios-plugins-ping nagios-plugins-disk nagios-plugins-http nagios-plugins-procs nagios-plugins-users wget

#####NRPE INSTALLATION#####
yum -y install nrpe
systemctl enable nrpe
systemctl start nrpe

#####Install custom mem monitor#####
wget -O /usr/lib64/nagios/plugins/check_mem.sh https://raw.githubusercontent.com/chuanisawesome/NTI-320/master/resources/check_mem.sh
chmod +x /usr/lib64/nagios/plugins/check_mem.sh

#uncomment lines 323-327 (#####MISC SYSTEM METRICS#####)
sed -i '323,327 s/^#//' /etc/nagios/nrpe.cfg

#To remove last n characters of lines specified
sed -r -i 323,327's/.{6}$//' /etc/nagios/nrpe.cfg

#change the file during the process=use -i option (I am Appending a suffix at a specific line)
sed -i 323's/$/ -w 5 -c 10 &/' /etc/nagios/nrpe.cfg
sed -i 324's/$/ -w 15,10,5 -c 30,25,20 &/' /etc/nagios/nrpe.cfg
sed -i 325,326's/$/ -w 20% -c 10% &/' /etc/nagios/nrpe.cfg
sed -i 327's/$/ -w 70,40,30 -c 90,50,40 &/' /etc/nagios/nrpe.cfg

echo "command[check_mem]=/usr/lib/nagios/plugins/check_mem.sh -w 80 -c 90" >> /etc/nagios/nrpe.cfg

#escape square brackets
string='command\[check_hda1\]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /dev/hda1' 
replacement_string='command\[check_disk\]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /dev/sda1'
# use semicolons as delimiter
sed -i.bak "s;$string;$replacement_string;g" /etc/nagios/nrpe.cfg

### MISC SYSTEM METRICS ###
#sed -i 's;#command\[check_users\]=/usr/lib64/nagios/plugins/check_users $ARG1$;command\[check_users\]=/usr/lib64/nagios/plugins/check_users -w 5 -c 10;g' /etc/nagios/nrpe.cfg
#sed -i 's;#command\[check_load\]=/usr/lib64/nagios/plugins/check_load $ARG1$;command\[check_load\]=/usr/lib64/nagios/plugins/check_load -w 15,10,5 -c 30,25,20;g' /etc/nagios/nrpe.cfg
#sed -i 's;#command\[check_disk\]=/usr/lib64/nagios/plugins/check_disk $ARG1$;command\[check_disk\]=/usr/lib64/nagios/plugins/check_disk -w 20% -c 10%;g' /etc/nagios/nrpe.cfg
#sed -i 's;#command\[check_swap\]=/usr/lib64/nagios/plugins/check_swap $ARG1$;command\[check_swap\]=/usr/lib64/nagios/plugins/check_swap -w 20% -c 10%;g' /etc/nagios/nrpe.cfg
#sed -i 's;#command\[check_cpu_stats\]=/usr/lib64/nagios/plugins/check_cpu_stats.sh $ARG1$;command\[check_cpu_stats\]=/usr/lib64/nagios/plugins/check_cpu_stats.sh -w 70,40,30 -c 90,50,40;g' /etc/nagios/nrpe.cfg
#sed -i 's,#command\[check_mem\]=/usr/lib64/nagios/plugins/custom_check_mem -n $ARG1$,command\[check_mem\]=/usr/lib64/nagios/plugins/check_mem.sh -w 80 -c 90,g' /etc/nagios/nrpe.cfg


#####SERVER NAME#####
nagios_server="testingnagios"
#####INTERNAL IP#####
nagios_ip=$(gcloud compute instances list | grep $nagios_server | awk '{ print $4 }' | tail -1)

#####ALLOW NAGIOS SERVER#####
sed -i 's/allowed_hosts=127.0.0.1/allowed_hosts=127.0.0.1, '$nagios_ip'/g' /etc/nagios/nrpe.cfg

systemctl restart nrpe
