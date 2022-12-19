#!/bin/bash

echo "Start all services ...";
CURRENT_UID=$(id -u):$(id -g) docker compose -f docker-compose-kafka.yml start

./scripts/kafka/wait_services.sh