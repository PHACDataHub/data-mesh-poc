#!/bin/bash

CURRENT_UID=$(id -u):$(id -g) docker compose -f docker-compose-spark.yml down
