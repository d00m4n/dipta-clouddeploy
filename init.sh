#!/bin/sh

TEMPLATE_NAME="diptatmpt"
TEMPLATE_TYPE="e2-standard-2"
IMAGE_NAME="dipta-img"

#NODE01TYPE="e2-standard-2"
#NODE02TYPE="e2-standard-2"
#DOMAIN=$1
#TOKEN=$2

echo "Creating machine template."
gcloud compute instances create $TEMPLATE_NAME --image debian-10-buster-v20201014 --image-project debian-cloud --machine-type $TEMPLATE_TYPE
#gcloud compute instances create $NODE01 --image debian-10-buster-v20201014 --image-project debian-cloud --machine-type $NODE01TYPE
#gcloud compute instances create $NODE02 --image debian-10-buster-v20201014 --image-project debian-cloud --machine-type $NODE02TYPE

sleep 10 
#echo "Getting IPs"
#MASTERIP=$(gcloud compute instances describe $MASTER --format='get(networkInterfaces[0].networkIP)')
#NODE1IP=$(gcloud compute instances describe $NODE01 --format='get(networkInterfaces[0].networkIP)')
#NODE2IP=$(gcloud compute instances describe $NODE02 --format='get(networkInterfaces[0].networkIP)')
#PUBLIC_IP=$(gcloud compute instances describe dipta  --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
#OWNER_IP=$(curl raw.queip.info)

echo "Sending scripts to $TEMPLATE_NAME"
gcloud compute scp global.sh $TEMPLATE_NAME:/tmp
#gcloud compute scp master.sh $MASTER:/tmp

echo "Running master scripts"
gcloud compute ssh $TEMPLATE_NAME --command "sudo /tmp/global.sh"
#gcloud compute ssh $MASTER --command "sudo /tmp/master.sh $MASTER $MASTERIP $NODE1IP $NODE2IP"

echo "Stopping instance."
gcloud compute instances stop $TEMPLATE_NAME

echo "creating image."
gcloud beta compute machine-images create $IMAGE_NAME --source-instance  $TEMPLATE_NAME
exit
#echo "Sending scripts to $NODE01"
#gcloud compute scp global.sh $NODE01:/tmp
#gcloud compute scp worker.sh $NODE01:/tmp

#echo "Running worker scripts"
#gcloud compute ssh $NODE01 --command "sudo /tmp/global.sh"
#gcloud compute ssh $NODE01 --command "sudo /tmp/worker.sh $MASTER $MASTERIP $NODE1IP $NODE2IP"

#echo "Sending scripts to $NODE02"
#gcloud compute scp global.sh $NODE02:/tmp
gcloud compute scp worker.sh $NODE02:/tmp

echo "Running master scripts"
gcloud compute ssh $NODE02 --command "sudo /tmp/global.sh"
gcloud compute ssh $NODE02 --command "sudo /tmp/worker.sh $MASTER $MASTERIP $NODE1IP $NODE2IP"

echo "Setting External IPs"
curl https://www.duckdns.org/update/$DOMAIN/$TOKEN/$PUBLIC_IP
gcloud compute firewall-rules update traefik --source-ranges $OWNER_IP
gcloud compute instances add-tags $MASTER --tags http-server,https-server

echo "Final scrips"

gcloud compute scp getup.sh dipta:/tmp
gcloud compute ssh dipta --command "sudo mv /tmp/getup.sh /srv/docker/dipta-swarm && cd /srv/docker/dipta-swarm/ && sudo ./getup.sh"
gcloud compute ssh dipta

