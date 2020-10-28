cd /srv/docker/dipta-swarm
export REPO_PATH=$(pwd)
echo $REPO_PATH
echo "Launching Traefil"
docker stack deploy -c $REPO_PATH/traefik/stack.yaml traefik
echo "Launching Portainer"
docker stack deploy -c $REPO_PATH/portainer/stack.yaml portainer
echo "Launching Grafana"
$REPO_PATH/integra/integra.sh
