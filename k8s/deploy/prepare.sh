#!/bin/bash
set -e

# VERBOSE="/dev/null"
VERBOSE="/dev/stdout"

echo -n 'Building docker image to seed initial data into containers...'

docker build -t northamerica-northeast1-docker.pkg.dev/phsx-sp-sde-muffledstarling/data-mesh-poc/seed:v0.4 -f Dockerfile ../.. > $VERBOSE

echo ' ✅'

echo -n 'Pushing image to cluster...'
docker push northamerica-northeast1-docker.pkg.dev/phsx-sp-sde-muffledstarling/data-mesh-poc/seed:v0.4 > $VERBOSE
echo ' ✅'

echo -n 'Creating kubernetes volumes and setting up seeding job...'

kubectl apply -f volumes > $VERBOSE
# sleep 2
kubectl apply -f . > $VERBOSE

echo ' ✅'

echo -n 'Waiting for cluster to be ready... (can take up to 3 minutes)'

kubectl wait --timeout=3m --for=condition=complete job/prepare-mesh-volumes > $VERBOSE

echo '  ✅'

echo -n 'Creating deployments and services...'

kubectl apply -f .. > $VERBOSE

echo ' ✅'

echo 'Done.'
