#!/bin/bash

echo "Stopping all services ...";

sudo chmod -R a+rw vol*

docker exec -u $(id -u):$(id -g) zookeeper bash -c "chmod -R a+rw /var/lib/zookeeper/data /var/lib/zookeeper/log"
docker exec -u $(id -u):$(id -g) broker bash -c "chmod -R a+rw /var/lib/kafka/data"

CURRENT_UID=$(id -u):$(id -g) docker compose -f docker-compose-kafka.yml stop

echo "All services are stopped ✅";
