#!/bin/bash

echo "Start all services ...";
CURRENT_UID=$(id -u):$(id -g) docker compose -f docker-compose-spark.yml up -d --scale spark-worker=3
