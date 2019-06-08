#!/bin/bash
# make sure that instance is on Allow full access to all Cloud APIs
# make sure that the running instance has the startup script that is being used (local file)
#---------------------git clone repo-----------------------------#
yum install git -y
git clone https://github.com/chuanisawesome/NTI-320.git


#--------------spin up Repo Server instance---------------------#
repo_server="testingrepo"

gcloud compute instances create $repo_server \
    --zone us-west1-b \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --image-family centos-7 \
    --image-project centos-cloud \
    --tags "http-server","https-server" \
    --metadata-from-file startup-script="/NTI-320/final/repo-startup-script.sh"


#--------------spin up Build Server instance--------------------#
build_server="testingbuild"

gcloud compute instances create $build_server \
    --zone us-west1-b \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --image-family centos-7 \
    --image-project centos-cloud \
    --tags "http-server","https-server" \
    --metadata-from-file startup-script="/NTI-320/final/build-startup-script.sh"


#--------------spin up Nagios Server instance--------------------#
nagios_server="testingnagios"

gcloud compute instances create $nagios_server \
    --zone us-west1-b \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --image-family centos-7 \
    --image-project centos-cloud \
    --tags "http-server","https-server" \
    --metadata-from-file startup-script="/NTI-320/final/nagios-startup-script.sh"
    

#--------------spin up Cacti Server instance--------------------#
cacti_server="testingcacti"

gcloud compute instances create $cacti_server \
    --zone us-west1-b \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --image-family centos-7 \
    --image-project centos-cloud \
    --tags "http-server","https-server" \
    --metadata-from-file startup-script="/NTI-320/final/cacti-startup-script.sh"
    
    
#--------------spin up Nagios & Cacti Client instance--------------------#
nagios_cacti_client="testingncclient"

gcloud compute instances create $nagios_cacti_client \
    --zone us-west1-b \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --image-family centos-7 \
    --image-project centos-cloud \
    --tags "http-server","https-server" \
    --metadata-from-file startup-script="/NTI-320/final/nagios-cacti-client-startup-script.sh"


#---------------spin up Rsyslog Server instance------------------#
rsyslog_server="testingrsyslog"

gcloud compute instances create $rsyslog_server \
    --zone us-west1-b \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --image-family centos-7 \
    --image-project centos-cloud \
    --metadata-from-file startup-script="/NTI-320/final/rsyslog-startup-script.sh"

rsyslog_ip=$(gcloud compute instances list | grep $rsyslog_server | awk '{ print $4 }' | tail -1)

ldapserver=/NTI-320/final/ldap-startup-script.sh
sed -i "s/\$rsys_ip/$rsyslog_ip/g" $ldapserver

nfsserver=/NTI-320/final/nfs-startup-script.sh
sed -i "s/\$rsys_ip/$rsyslog_ip/g" $nfsserver

postgresserver=/NTI-320/final/postgres-startup-script.sh
sed -i "s/\$rsys_ip/$rsyslog_ip/g" $postgresserver

djangoserver=/NTI-320/final/django-startup-script.sh
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
    --metadata-from-file startup-script="/NTI-320/final/ldap-startup-script.sh"


#---------------spin up NFS Server instance---------------------#
nfs_server="testingnfs"

gcloud compute instances create $nfs_server \
    --zone us-west1-b \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --image-family centos-7 \
    --image-project centos-cloud \
    --tags "http-server","https-server" \
    --metadata-from-file startup-script="/NTI-320/final/nfs-startup-script.sh"

nfs_ip=$(gcloud compute instances list | grep $nfs_server | awk '{ print $4 }' | tail -1)

##sed line that changes ip in the client file
lnclient=/NTI-320/final/ldap-nfs-client-startup-script.sh
sed -i "s/\$nfs_ip/$nfs_ip/g" $lnclient
sed -i "s/\$ldap_ip/$ldap_ip/g" $lnclient

sleep 2

#--------------spin up LDAP & NFS Client instance---------------#
ldap_nfs_client="testinglnc"

gcloud compute instances create $ldap_nfs_client \
    --zone us-west1-b \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --image-family ubuntu-1604-lts \
    --image-project ubuntu-os-cloud \
    --metadata-from-file startup-script="/NTI-320/final/ldap-nfs-client-startup-script.sh"


#--------------spin up Posgres Server instance------------------#
postgres_server="testingpost"

gcloud compute instances create $postgres_server \
    --zone us-west1-b \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --image-family centos-7 \
    --image-project centos-cloud \
    --tags "http-server","https-server" \
    --metadata-from-file startup-script="/NTI-320/final/postgres-startup-script.sh"

post_ip=$(gcloud compute instances list | grep $postgres_server | awk '{ print $4 }' | tail -1)

django=/NTI-320/final/django-startup-script.sh
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
    --tags "http-server","django-server" \
    --metadata-from-file startup-script="/NTI-320/final/django-startup-script.sh"
 

#---------------------start of for-loops-------------------------#
sleep 2

for servername in $(gcloud compute instances list | awk '{print $1}' | sed "1 d" | grep -v $nagios_server); do 

gcloud compute ssh cchang30@$servername --zone us-west1-b --strict-host-key-checking='no' --command='sudo yum -y install wget && sudo wget https://raw.githubusercontent.com/chuanisawesome/NTI-320/master/lab1_nagios/nagios_client_install.sh && sudo bash nagios_client_install.sh';

done

sleep 2

for servername in $(gcloud compute instances list | awk '{print $1}' | sed "1 d" | grep -v $rsyslog_server); do 

gcloud compute ssh cchang30@$servername --zone us-west1-b --strict-host-key-checking='no' --command='sudo yum -y install wget && sudo wget https://raw.githubusercontent.com/chuanisawesome/NTI-320/master/lab1_nagios/nagios_client_install.sh && sudo bash nagios_client_install.sh';

done
