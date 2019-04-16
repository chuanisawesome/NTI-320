#!/bin/bash

#####INSTALL APACHE#####
yum -y install httpd
systemctl enable httpd
systemctl start httpd
