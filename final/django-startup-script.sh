#!/usr/bin/env bash

# be sure to change the server_name
# server_name=postgres
# postgres internal ip 
# in_ip=$(getent hosts  $server_name$(echo .$(hostname -f |  cut -d "." -f2-)) | awk '{ print $1 }' )

#----------------install packages-------------

yum install -y epel-release
yum install python-pip -y
pip install virtualenv
pip install --upgrade pip
yum install -y telnet

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

mkdir /opt/myproject
cd /opt/myproject

#-----------------virtual env----------------

virtualenv myprojectenv
source myprojectenv/bin/activate
pip install django
pip install psycopg2-binary
django-admin.py startproject myproject .

chown -R cchang30 . /opt/myproject

# django external ip
ex_ip=$( curl https://api.ipify.org )
sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \['"$ex_ip"'\]/g" /opt/myproject/myproject/settings.py

sed -i.bak '76,82d' /opt/myproject/myproject/settings.py

# be sure to change the server_name
 server_name=postgres
# postgres internal ip 
in_ip=$(getent hosts  $server_name$(echo .$(hostname -f |  cut -d "." -f2-)) | awk '{ print $1 }' )

# change the configuration to postgresql db
echo "DATABASES = {
    'default':{
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'myproject',
        'USER': 'myprojectuser',
        'PASSWORD': 'password',
        'HOST': '$in_ip',
        'PORT': '5432',
    }
}" >> /opt/myproject/myproject/settings.py

python /opt/myproject/manage.py makemigrations
python /opt/myproject/manage.py migrate
# deletes and creates the superuser 
echo "from django.contrib.auth.models import User; User.objects.filter(email='root@example.com').delete(); User.objects.create_superuser('root', 'root@example.com', 'password')" | python manage.py shell

# exit to normal user (username)
# start django test server
#sudo -u cchang30 -E sh -c "\\
source /opt/myproject/myprojectenv/bin/activate && python /opt/myproject/manage.py runserver 0.0.0.0:8000&
