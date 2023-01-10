#!/bin/bash

./scripts/spark/stop.sh
echo ''

CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

docker compose -f docker-compose-spark.yml down
