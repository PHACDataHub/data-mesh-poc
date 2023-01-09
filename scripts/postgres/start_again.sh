#!/bin/bash

CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

echo "Start all services ...";
docker compose -f docker-compose-postgres.yml start
echo "All services are started ✅";