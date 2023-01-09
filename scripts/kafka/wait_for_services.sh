#!/bin/bash

zookeeper=zookeeper:2181
broker=broker:29092
schema_registry_host=schema-registry
schema_registry_port=8081
rest_proxy_host=rest-proxy
rest_proxy_port=8082
connect_host=connect
connect_port=8083
ksqldb_server_host=ksqldb-server
ksqldb_server_port=8088
control_center_host=control-center
control_center_port=9021

timeout=600

echo "Wait for ${zookeeper} ...";
docker exec -it zookeeper cub zk-ready $zookeeper $timeout >> kafka-wait-for-services.log
echo "${zookeeper} is ready ✅";

echo "Wait for ${broker} ...";
docker exec -it zookeeper cub kafka-ready -b $broker 1 $timeout >> kafka-wait-for-services.log
echo "${broker} is ready ✅";

echo "Wait for ${schema_registry_host}:${schema_registry_port} ...";
docker exec -it zookeeper cub sr-ready $schema_registry_host $schema_registry_port $timeout >> kafka-wait-for-services.log
echo "${schema_registry_host}:${schema_registry_port} is ready ✅";

echo "Wait for ${rest_proxy_host}:${rest_proxy_port} ...";
docker exec -it zookeeper cub kr-ready $rest_proxy_host $rest_proxy_port $timeout >> kafka-wait-for-services.log
echo "${rest_proxy_host}:${rest_proxy_port} is ready ✅";

echo "Wait for ${connect_host}:${connect_port} ...";
docker exec -it zookeeper cub connect-ready $connect_host $connect_port $timeout >> kafka-wait-for-services.log
echo "${connect_host}:${connect_port} is ready ✅";

echo "Wait for ${ksqldb_server_host}:${ksqldb_server_port} ...";
docker exec -it zookeeper cub ksql-server-ready $ksqldb_server_host $ksqldb_server_port $timeout >> kafka-wait-for-services.log
echo "${ksqldb_server_host}:${ksqldb_server_port} is ready ✅";

echo "Wait for ${control_center_host}:${control_center_port} ...";
docker exec -it zookeeper cub control-center-ready $control_center_host $control_center_port $timeout >> kafka-wait-for-services.log
echo "${control_center_host}:${control_center_port} is ready ✅";

echo "Kafka cluster is ready ✅";
