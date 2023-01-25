#!/bin/bash

# Copy tar file from git repo into cloud volume
mv /data/* data
mv /plugins/* kafka/plugins

# Execute kafka setup script
./scripts/kafka/setup.sh

echo "Setting up permissions..."

# Setup permissions on volumes
chown -R 1000 /src/vol1
chown -R 1000 /src/vol2
chown -R 1000 /src/data
chown -R 1000 /src/kafka/plugins
mkdir /broker/data
chown -R 1000 /broker
