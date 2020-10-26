#!/bin/sh

MASTER="dipta"
NODE01="dipta01"
NODE02="dipta02"
DOMAIN=$1
TOKEN=$2

echo "Creating Machines"
gcloud compute instances create $MASTER --image debian-10-buster-v20201014 --image-project debian-cloud
gcloud compute instances create $NODE01 --image debian-10-buster-v20201014 --image-project debian-cloud
gcloud compute instances create $NODE02 --image debian-10-buster-v20201014 --image-project debian-cloud


echo "Getting IPs"
MASTERIP=$(gcloud compute instances describe $MASTER --format='get(networkInterfaces[0].networkIP)')
NODE1IP=$(gcloud compute instances describe $NODE01 --format='get(networkInterfaces[0].networkIP)')
NODE2IP=$(gcloud compute instances describe $NODE02 --format='get(networkInterfaces[0].networkIP)')
PUBLIC_IP=$(gcloud compute instances describe dipta  --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
OWNER_IP=$(curl raw.queip.info)

echo "Sending scripts to $MASTER"
gcloud compute scp global.sh $MASTER:/tmp
gcloud compute scp master.sh $MASTER:/tmp

echo "Running master scripts"
gcloud compute ssh $MASTER --command "sudo /tmp/global.sh"
gcloud compute ssh $MASTER --command "sudo /tmp/master.sh $MASTER $MASTERIP $NODE1IP $NODE2IP"

echo "Sending scripts to $NODE01"
gcloud compute scp global.sh $NODE01:/tmp
gcloud compute scp worker.sh $NODE01:/tmp

echo "Running worker scripts"
gcloud compute ssh $NODE01 --command "sudo /tmp/global.sh"
gcloud compute ssh $NODE01 --command "sudo /tmp/worker.sh $MASTER $MASTERIP $NODE1IP $NODE2IP"

echo "Sending scripts to $NODE02"
gcloud compute scp global.sh $NODE02:/tmp
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


