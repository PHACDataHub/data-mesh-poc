#!/bin/bash

echo 'Post processing ...'
docker exec -u neo4j --interactive --tty  neo4j cypher-shell -u neo4j -p phac2022 --file /import/neo4j_post_processing.cql
echo 'Post processing completed ✅'
