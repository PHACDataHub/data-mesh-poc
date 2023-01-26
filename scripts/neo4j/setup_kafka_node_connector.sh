#!/bin/bash

connect=localhost:8083

echo "Listing all connectors ...";
curl -s ${connect}/connectors | jq '.[]'

curl -X POST http://${connect}/connectors \
  -H 'Content-Type:application/json' \
  -H 'Accept:application/json' \
  -d @conf/neo4j_node_sink_connector.json

echo "Listing all connectors ...";
curl -s ${connect}/connectors | jq '.[]'