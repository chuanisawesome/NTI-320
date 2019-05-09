#!/bin/bash

for servername in $(gcloud compute instances list | awk '{print $1}' | sed "1 d" | grep -v nagios-a);  do 
    echo $servername;
    serverip=$( gcloud compute instances list | grep $servername | awk '{print $4}');
    echo $serverip ;
    
    bash scp-to-nagios.sh $servername $serverip
done

gcloud compute ssh --zone us-west1-b cchang30@testingnagios --command='sudo systemctl restart nagios'
