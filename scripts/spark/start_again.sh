#!/bin/bash

echo "Start all services ...";
CURRENT_UID=$(id -u):$(id -g) docker compose -f docker-compose-spark.yml start
