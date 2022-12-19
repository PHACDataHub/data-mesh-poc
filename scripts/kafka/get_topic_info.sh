#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage ./scripts/kafka/get_topic_info.sh <topic_name>"
    exit 0
fi

broker=broker:29092
schema_registry=http://schema-registry:8081

docker exec kafkacat \
    kafkacat -b ${broker} -t $1 -o-1 \
             -C -J \
             -s key=s -s value=avro -r ${schema_registry} | \
             jq '{"key":.key,"payload": .payload}'
