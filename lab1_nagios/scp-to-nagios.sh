#!/bin/bash

bash generate_config.sh $1 $2

gcloud compute scp --zone us-west1-b $1.cfg cchang30@nagios-a:/etc/nagios/servers

# Note: I had to add user nicolebade to group nagios using usermod -a -G nagios nicolebade
# I also had to chmod 775 /etc/nagios/servers
#usermod -a -G nagios nicolebade

gcloud compute ssh --zone us-west1-b cchang30@nagios-a --command='sudo /usr/sbin/nagios -v /etc/nagios/nagios.cfg'


