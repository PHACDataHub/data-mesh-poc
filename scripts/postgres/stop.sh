#!/bin/bash

CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

echo "Stopping all services ...";
docker compose -f docker-compose-postgres.yml stop
echo "All services are stopped ✅";
