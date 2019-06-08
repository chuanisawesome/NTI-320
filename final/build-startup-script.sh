#!/bin/bash

# install the correct programs for building & dependencies needed:
yum -y install rpm-build make gcc git

# to wget things from the web 
yum -y install wget

# Create the directory structure we'll use for our build process:
mkdir -p -v /root/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

cd ~/
 # Set the rpmbuild path in an .rpmmacros file
echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros
cd ~/rpmbuild/SOURCES

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

#git clone
#cp NTI-320/rpm-info/hello_world_from_source/helloworld-0.1.tar.gz .
#.sh
#.spec
#mv .spec ../SPECS
#cd ..

# to_build
#rpmbuild -v -bb --clean SPECS/hello.spec


#yum -y install RPMS/x86_64/helloworld-0.1-1.el7.x86_64.rpm
