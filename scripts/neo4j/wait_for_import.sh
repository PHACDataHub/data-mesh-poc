#!/bin/bash

echo "Waiting for all nodes imported ... "

NODE_COUNT=$(docker exec --interactive --tty neo4j bash -c "echo 'MATCH (n) RETURN COUNT(n) AS c' |  cypher-shell -u neo4j -p phac2022  | tail -n 1 | tr -d '\n'")

while [ "$NODE_COUNT" != "854114" ]
do
    NODE_COUNT=$(docker exec --interactive --tty neo4j bash -c "echo 'MATCH (n) RETURN COUNT(n) AS c' |  cypher-shell -u neo4j -p phac2022  | tail -n 1 | tr -d '\n'")
    echo $NODE_COUNT
    sleep 1
done

echo "${NODE_COUNT} nodes were imported ✅";
