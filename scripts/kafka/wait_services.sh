#!/bin/bash

zookeeper=localhost:2181
broker=localhost:9092
schema_registry=localhost:8081
rest_proxy=localhost:8082
ksqldb_server=localhost:8088
control_center=localhost:9021
connect=localhost:8083

for item in $zookeeper $broker $ksqldb_server $control_center $schema_registry $rest_proxy $connect
do
    echo "Wait for ${item} ...";
    ./scripts/kafka/wait-for-it.sh ${item}
    echo "${item} is ready ✅";
done

echo "Kafka cluster is ready ✅";
