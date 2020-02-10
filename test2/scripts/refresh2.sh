#!/bin/sh

docker-compose -f docker-compose-cli3.yaml down

# STOP AND DELETE THE DOCKER CONTAINERS
docker ps -aq | xargs -n 1 docker stop
docker ps -aq | xargs -n 1 docker rm -v

# DELETE THE OLD DOCKER VOLUMES
docker volume prune -f

# DELETE OLD DOCKER NETWORKS (OPTIONAL: seems to restart fine without)
docker network prune -f

# VERIFY RESULTS
docker ps -a
docker volume ls