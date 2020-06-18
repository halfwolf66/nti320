
#!/bin/bash
for servername in $( gcloud compute instances list | awk '{print $1}' | sed "1 d" | grep -v nagios );  do 
    echo $servername;
    serverip=$( gcloud compute instances list | grep $servername | awk '{print $4}');
    echo $serverip ;
    bash scp_to_nagios.sh $servername $serverip
done
gcloud compute ssh --zone us-central1-a irishman253@nagios --command='sudo systemctl restart nagios'
