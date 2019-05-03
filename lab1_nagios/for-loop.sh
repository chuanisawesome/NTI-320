#!/bin/bash

for servername in $(gcloud compute instances list | awk '{print $1}' | sed "1 d" );  do 
    echo $servername;
    serverip=$( gcloud compute instances list | grep $servername | awk '{print $4}');
    echo $serverip ;
done
