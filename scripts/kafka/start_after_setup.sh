#!/bin/bash
set -e

CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)
OSTYPE=$(uname -s)

if [ ! -d "vol1" ]; then
    echo "Please run ./scripts/setup.sh";
fi

echo "Start all services ...";
if [[ $OSTYPE == 'Linux' ]]; then
    docker compose -f docker-compose-kafka.yml up -d
fi
if [[ $OSTYPE == 'Darwin' ]]; then
    docker compose -f docker-compose-kafka-osx.yml up -d
fi

echo "All services are started ✅";

./scripts/kafka/wait_for_services.sh

echo "test"
