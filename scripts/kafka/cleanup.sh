#!/bin/bash

./scripts/kafka/stop.sh

CURRENT_UID=$(id -u):$(id -g) docker compose -f docker-compose-kafka.yml down

echo "Removing instance files ...";
sudo rm -rf vol*
sudo rm -rf data/error data/unprocessed data/processed

echo "Instance files removed ✅";
