#!/bin/bash

CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

echo "Start all services ...";
docker compose -f docker-compose-spark.yml up -d --scale spark-worker=3
echo "All services are started ✅";