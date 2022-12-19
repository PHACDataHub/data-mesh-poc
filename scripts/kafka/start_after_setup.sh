#!/bin/bash

if [ ! -d "vol1" ]; then
    echo "Please run ./scripts/setup.sh";
fi

echo "Start all services ...";
CURRENT_UID=$(id -u):$(id -g) docker compose -f docker-compose-kafka.yml up -d

./scripts/kafka/wait_services.sh
