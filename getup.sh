cd /srv/docker/dipta-swarm
export REPO_PATH=$(pwd)
echo $REPO_PATH
docker stack deploy -c $REPO_PATH/traefik/stack.yaml traefik
docker stack deploy -c $REPO_PATH/portainer/stack.yaml portainer
