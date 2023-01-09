#!/bin/bash

CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

if [ ! -d "vol1" ]; then
    echo "Please run ./scripts/setup.sh";
fi

echo "Start all services ...";
docker compose -f docker-compose-kafka.yml up -d
echo "All services are started ✅";

./scripts/kafka/wait_for_services.sh
