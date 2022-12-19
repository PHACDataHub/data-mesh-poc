#!/bin/bash

echo "Stopping all services ...";

CURRENT_UID=$(id -u):$(id -g) docker compose -f docker-compose-postgres.yml stop

echo "All services are stopped ✅";
