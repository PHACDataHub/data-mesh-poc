#!/bin/bash

cp data/csv/ctytoarp.csv data/unprocessed/.;
chmod a+rw data/unprocessed/ctytoarp.csv;

connect=localhost:8083
internal_broker=broker:29092

echo "Listing all connectors ...";
curl -s ${connect}/connectors | jq '.[]'

echo "Listing all topics ...";
docker exec kafkacat kafkacat -b ${internal_broker} -q -L  -J | jq '.topics[].topic' | sort

curl -i -X PUT -H "Accept:application/json" \
    -H  "Content-Type:application/json" http://${connect}/connectors/spooldir_ctytoarp/config \
    -d '{
        "connector.class":"com.github.jcustenborder.kafka.connect.spooldir.SpoolDirCsvSourceConnector",
        "topic":"topic_ctytoarp",
        "input.path":"/data/unprocessed",
        "finished.path":"/data/processed",
        "error.path":"/data/error",
        "input.file.pattern":"ctytoarp.csv",
        "schema.generation.enabled":"true",
        "schema.generation.key.fields":"fips",
        "csv.first.row.as.header":"true",
        "transforms.castTypes.type":"org.apache.kafka.connect.transforms.Cast$Value",
        "transforms.castTypes.spec":"distance:float32"
        }'


echo "Listing all connectors ...";
curl -s ${connect}/connectors | jq '.[]'

echo "Listing all topics ...";
docker exec kafkacat kafkacat -b ${internal_broker} -q -L  -J | jq '.topics[].topic' | sort
