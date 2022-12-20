#!/bin/bash

CURRENT_UID=$(id -u):$(id -g) docker compose -f docker-compose-neo4j.yml down

sudo rm -rf data/neo4j