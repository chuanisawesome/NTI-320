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

git clone https://github.com/nic-instruction/custom-nrpe-2019.git
cd custom-nrpe-2019
cp custom-nrpe-2019/nti-320-plugins-0.1.tar.gz .
cp custom-nrpe-2019/plugins/connectiontest.sh .
cp custom-nrpe-2019/nti-320-plugins.spec .
#.sh
#.spec
mv nti-320-plugins.spec ../SPECS
cd ..

# to_build
rpmbuild -v -bb --clean SPECS/hello.spec


yum -y install RPMS/x86_64/nti-320-plugins-0.1-1.el7.x86_64.rpm
