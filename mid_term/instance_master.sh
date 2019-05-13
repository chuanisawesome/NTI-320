#!/bin/bash
# make sure that instance is on Allow full access to all Cloud APIs
# make sure that the running instance has the startup script that is being used (local file)
#---------------------git clone repo-----------------------------#
yum install git -y
yum install wget -y
git clone https://github.com/chuanisawesome/NTI-320.git
wget https://raw.githubusercontent.com/chuanisawesome/NTI-320/master/lab1_nagios/generate_config.sh
wget https://raw.githubusercontent.com/chuanisawesome/NTI-320/master/lab1_nagios/scp-to-nagios.sh


#--------------spin up Nagios Server instance--------------------#
nagios_server="testingnagios"

gcloud compute instances create $nagios_server \
    --zone us-west1-b \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --image-family centos-7 \
    --image-project centos-cloud \
    --tags "http-server","https-server" \
    --metadata-from-file startup-script="/NTI-320/mid_term/nagios-startup-script.sh"
    

#--------------spin up Cacti Server instance--------------------#
cacti_server="testingcacti"

gcloud compute instances create $cacti_server \
    --zone us-west1-b \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --image-family centos-7 \
    --image-project centos-cloud \
    --tags "http-server","https-server" \
    --metadata-from-file startup-script="/NTI-320/mid_term/cacti-startup-script.sh"
    
    
#--------------spin up Nagios & Cacti Client instance--------------------#
nagios_cacti_client="testingncclient"

gcloud compute instances create $nagios_cacti_client \
    --zone us-west1-b \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --image-family centos-7 \
    --image-project centos-cloud \
    --tags "http-server","https-server" \
    --metadata-from-file startup-script="/NTI-320/mid_term/nagios-cacti-client-startup-script.sh"


#---------------spin up Rsyslog Server instance------------------#
rsyslog_server="testingrsyslog"

gcloud compute instances create $rsyslog_server \
    --zone us-west1-b \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --image-family centos-7 \
    --image-project centos-cloud \
    --metadata-from-file startup-script="/NTI-320/mid_term/rsyslog-startup-script.sh"

rsyslog_ip=$(gcloud compute instances list | grep $rsyslog_server | awk '{ print $4 }' | tail -1)

ldapserver=/NTI-320/mid_term/ldap-startup-script.sh
sed -i "s/\$rsys_ip/$rsyslog_ip/g" $ldapserver

nfsserver=/NTI-320/mid_term/nfs-startup-script.sh
sed -i "s/\$rsys_ip/$rsyslog_ip/g" $nfsserver

postgresserver=/NTI-320/mid_term/postgres-startup-script.sh
sed -i "s/\$rsys_ip/$rsyslog_ip/g" $postgresserver

djangoserver=/NTI-320/mid_term/django-startup-script.sh
sed -i "s/\$rsys_ip/$rsyslog_ip/g" $djangoserver

sleep 2

#---------------spin up LDAP Server instance---------------------#
ldap_server="testingldap"

gcloud compute instances create $ldap_server \
    --zone us-west1-b \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --image-family centos-7 \
    --image-project centos-cloud \
    --tags "http-server","https-server" \
    --metadata-from-file startup-script="/NTI-320/mid_term/ldap-startup-script.sh"


#---------------spin up NFS Server instance---------------------#
nfs_server="testingnfs"

gcloud compute instances create $nfs_server \
    --zone us-west1-b \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --image-family centos-7 \
    --image-project centos-cloud \
    --tags "http-server","https-server" \
    --metadata-from-file startup-script="/NTI-320/mid_term/nfs-startup-script.sh"

nfs_ip=$(gcloud compute instances list | grep $nfs_server | awk '{ print $4 }' | tail -1)

##sed line that changes ip in the client file
lnclient=/NTI-320/mid_term/ldap-nfs-client-startup-script.sh
sed -i "s/\$nfs_ip/$nfs_ip/g" $lnclient
sed -i "s/\$ldap_ip/$ldap_ip/g" $lnclient

sleep 5

#--------------spin up LDAP & NFS Client instance---------------#
ldap_nfs_client="testinglnc"

gcloud compute instances create $ldap_nfs_client \
    --zone us-west1-b \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --image-family ubuntu-1604-lts \
    --image-project ubuntu-os-cloud \
    --metadata-from-file startup-script="/NTI-320/mid_term/ldap-nfs-client-startup-script.sh"


#--------------spin up Posgres Server instance------------------#
postgres_server="testingpost"

gcloud compute instances create $postgres_server \
    --zone us-west1-b \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --image-family centos-7 \
    --image-project centos-cloud \
    --tags "http-server","https-server" \
    --metadata-from-file startup-script="/NTI-320/mid_term/postgres-startup-script.sh"

post_ip=$(gcloud compute instances list | grep $postgres_server | awk '{ print $4 }' | tail -1)

django=/NTI-320/mid_term/django-startup-script.sh
# to get postgres internal ip
sed -i "s/\$server_name/$postgres_server/g" $django

sleep 2

#--------------spin up Django Server instance-------------------#
django_server="testingdjango"

gcloud compute instances create $django_server \
    --zone us-west1-b \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --image-family centos-7 \
    --image-project centos-cloud \
    --tags "http-server", "port-8000" \
    --metadata-from-file startup-script="/NTI-320/mid_term/django-startup-script.sh"

#for servername in $(gcloud compute instances list | awk '{print $1}' | sed "1 d" | grep -v $nagios_server); do 

#gcloud compute ssh --zone us-west1-b cchang30@$servername --command='sudo yum -y install wget && sudo wget https://raw.githubusercontent.com/chuanisawesome/NTI-320/master/lab1_nagios/nagios_client_install.sh && chmod 777 nagios_client_install.sh && sudo ./nagios_client_install.sh';

#done

#sleep 2

#for servername in $(gcloud compute instances list | awk '{print $1}' | sed "1 d" | grep -v $nagios_server);  do 
#    echo $servername;
#    serverip=$( gcloud compute instances list | grep $servername | awk '{print $4}');
#    echo $serverip ;
    
#    ./scp-to-nagios.sh $servername $serverip
#done

#gcloud compute ssh --zone us-west1-b cchang30@$nagios_server --command='sudo systemctl restart nagios'
