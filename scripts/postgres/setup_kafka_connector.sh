#!/bin/bash

connect=localhost:8083
postgres=postgres:5432
topic_name=topic_dailyc19
composite_keys=date,fips

curl -X PUT http://${connect}/connectors/sink-postgres/config \
    -H "Content-Type: application/json" \
    -d '{
        "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
        "connection.url": "jdbc:postgresql://'${postgres}'/",
        "connection.user": "postgres",
        "connection.password": "postgres",
        "tasks.max": "1",
        "topics": "'${topic_name}'",
        "auto.create": "true",
        "auto.evolve":"true",
        "pk.mode":"record_value",
        "pk.fields":"'${composite_keys}'",
        "insert.mode": "upsert",
        "table.name.format":"'${topic_name}'"
    }'
    
curl -s "http://"${connect}"/connectors?expand=info&expand=status" | \
	jq '. | to_entries[] | [ .value.info.type, .key, .value.status.connector.state, .value.status.tasks[].state, .value.info.config."connector.class" ] | join (":|:")' | \
	column -s : -t | sed 's/\"//g' |sort 
    
topic_name=CALIFORNIA_COVID
composite_keys=DATE,FIPS

curl -X PUT http://${connect}/connectors/sink-california-covid/config \
    -H "Content-Type: application/json" \
    -d '{
        "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
        "connection.url": "jdbc:postgresql://'${postgres}'/",
        "connection.user": "postgres",
        "connection.password": "postgres",
        "tasks.max": "1",
        "topics": "'${topic_name}'",
        "auto.create": "true",
        "auto.evolve": "true",
        "pk.mode": "record_value",
        "pk.fields":"'${composite_keys}'",
        "insert.mode": "upsert",
        "table.name.format":"'${topic_name}'"
    }'

curl -s "http://"${connect}"/connectors?expand=info&expand=status" | \
	jq '. | to_entries[] | [ .value.info.type, .key, .value.status.connector.state, .value.status.tasks[].state, .value.info.config."connector.class" ] | join (":|:")' | \
	column -s : -t | sed 's/\"//g' |sort 
