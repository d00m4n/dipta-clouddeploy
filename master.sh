echo "Deploying master $1"

apt install -y nfs-kernel-server
mkdir -m 1777 /srv/nfs
echo "$2:/srv/nfs /srv/docker nfs defaults,nfsvers=3 0 0" >> /etc/fstab
echo "/srv/nfs $2(rw,no_root_squash,no_subtree_check) $3(rw,no_root_squash,no_subtree_check) $4(rw,no_root_squash,no_subtree_check) " >> /etc/exports
systemctl restart nfs-kernel-server
mount -a

echo "Initializing swarm"
docker swarm init 
docker swarm join-token manager|grep join  > /srv/docker/join.sh
chmod +x  /srv/docker/join.sh

echo "creating networks"
docker network create proxy -d overlay
docker network create portainer_agent -d overlay

echo "Downloading Repo"
cd /srv/docker
git clone https://github.com/d00m4n/dipta-swarm

