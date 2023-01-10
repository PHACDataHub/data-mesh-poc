#!/bin/bash

./scripts/neo4j/stop.sh
echo ''

CURRENT_UID=$(id -u):$(id -g) docker compose -f docker-compose-neo4j.yml down

sudo rm -rf neo4j