#!/bin/bash

echo "Waiting for all nodes imported ... ";
NODE_COUNT=$(docker exec --interactive --tty neo4j bash -c "echo 'MATCH (n) RETURN COUNT(n) AS c' |  cypher-shell -u neo4j -p phac2022  | tail -n 1")
echo $NODE_COUNT

until [ $NODE_COUNT != "854114" ]
do
    NODE_COUNT=$(docker exec --interactive --tty neo4j bash -c "echo 'MATCH (n) RETURN COUNT(n) AS c' |  cypher-shell -u neo4j -p phac2022  | tail -n 1")
    echo $NODE_COUNT
    sleep 1
done
echo $NODE_COUNT "nodes are imported ✅";
