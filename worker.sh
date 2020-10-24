echo "Deploying worker $1"

echo "configure NFS"
apt install -y nfs-common

echo "$2:/srv/nfs /srv/docker nfs defaults,nfsvers=3 0 0" >> /etc/fstab
echo "/srv/nfs $2(rw,no_root_squash,no_subtree_check) $3(rw,no_root_squash,no_subtree_check) $4(rw,no_root_squash,no_subtree_check) " >> /etc/exports

mount -a

echo "Joining swarm Cluster"
/srv/docker/join.sh
