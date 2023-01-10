#!/bin/bash

CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)
OSTYPE=$(uname -s)

echo "Start all services ...";
if [[ $OSTYPE == 'Linux' ]]; then
    docker compose -f docker-compose-kafka.yml start
fi
if [[ $OSTYPE == 'Darwin' ]]; then
    docker compose -f docker-compose-kafka-osx.yml start
fi
echo "All services are started ✅";

./scripts/kafka/wait_for_services.sh