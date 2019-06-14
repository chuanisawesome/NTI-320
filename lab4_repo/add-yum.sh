#!/bin/bash

repo_server="testingrepo"
#####INTERNAL IP#####
repo_ip=$(gcloud compute instances list | grep $repo_server | awk '{ print $4 }' | tail -1)

echo '[nti-320-plugins]
name=Extra Packages for Centos from NTI-320 7 - $basearch
#baseurl=http://download.fedoraproject.org/pub/epel/7/$basearch <- example epel repo
# Note, this is putting repodata at packages instead of 7 and our path is a hack around that.
baseurl=http://$repo_ip/centos/7/extras/x86_64/Packages/
enabled=1
gpgcheck=0
' >> /etc/yum.repos.d/NTI-320.repo 
