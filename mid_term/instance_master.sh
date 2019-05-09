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


nagios_ip=$(gcloud compute instances list | grep $nagios_server | awk '{ print $4 }' | tail -1)
echo "This is your internal nagios_ip $nagios_ip" >> instances_ip.txt

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


nagios_ip=$(gcloud compute instances list | grep $cacti_server | awk '{ print $4 }' | tail -1)
echo "This is your internal cacti_ip $cacti_ip" >> instances_ip.txt

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


ldap_ip=$(gcloud compute instances list | grep $ldap_server | awk '{ print $4 }' | tail -1)
echo "This is your internal ldap_ip $ldap_ip" >> instances_ip.txt


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
echo "This is your internal nfs_ip $nfs_ip" >> instances_ip.txt

##sed line that changes ip in the client file
lnclient=/NTI-310/mid_term/ldap-nfs-client-startup-script.sh
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

lnc_ip=$(gcloud compute instances list | grep $ldap_nfs_client | awk '{ print $4 }' | tail -1)
echo "This is your internal clients_ip $lnc_ip" >> instances_ip.txt


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
echo "This is your internal postgres_ip $post_ip" >> instances_ip.txt

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
    --tags "http-server" \
    --metadata-from-file startup-script="/NTI-320/mid_term/django-startup-script.sh"

    
django_ip=$(gcloud compute instances list | grep $django_server | awk '{ print $4 }' | tail -1)
echo "This is your internal django_ip $django_ip" >> instances_ip.txt


dir=/NTI-320/mid_term/ip.sh
if [ -f $dir ]
then 
   sed -i "s/\$ldap_server/$ldap_server/g" $dir
   sed -i "s/\$nfs_server/$nfs_server/g" $dir
   sed -i "s/\$ldap_nfs_client/$ldap_nfs_client/g" $dir
   sed -i "s/\$postgres_server/$postgres_server/g" $dir
   sed -i "s/\$django_server/$django_server/g" $dir
fi

mv $dir ./ip.sh | /bin/bash

for servername in $(gcloud compute instances list | awk '{print $1}' | sed "1 d" | grep -v $nagios_server); do 

gcloud compute ssh --zone us-west1-b cchang30@$servername --command='sudo yum -y install wget && sudo wget https://raw.githubusercontent.com/chuanisawesome/NTI-320/master/lab1_nagios/nagios_client_install.sh && sudo bash nagios_client_install.sh';

done

sleep 2

for servername in $(gcloud compute instances list | awk '{print $1}' | sed "1 d" | grep -v $nagios_server);  do 
    echo $servername;
    serverip=$( gcloud compute instances list | grep $servername | awk '{print $4}');
    echo $serverip ;
    
    bash scp-to-nagios.sh $servername $serverip
done

gcloud compute ssh --zone us-west1-b cchang30@$nagios_server --command='sudo systemctl restart nagios'
