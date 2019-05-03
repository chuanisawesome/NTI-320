for servername in $(gcloud compute instances list | awk '{print $1}' | sed "1 d" | grep -v nagios-a); do 
gcloud compute ssh --zone us-west1-b cchang30@$servername --command='sudo yum -y install wget && sudo wget https://raw.githubusercontent.com/chuanisawesome/NTI-320/master/lab1_nagios/nagios_client_install
.sh && sudo bash nagios_client_install.sh';

done
