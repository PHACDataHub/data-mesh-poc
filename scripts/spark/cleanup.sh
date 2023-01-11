#!/bin/bash

./scripts/spark/stop.sh
echo ''

CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

echo "Shutting down containers...";
docker compose -f docker-compose-spark.yml down
echo "Containers shutdown ✅";