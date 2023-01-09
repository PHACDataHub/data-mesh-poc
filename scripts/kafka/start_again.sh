#!/bin/bash

CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

echo "Start all services ...";
docker compose -f docker-compose-kafka.yml start
echo "All services are started ✅";

./scripts/kafka/wait_for_services.sh