#!/bin/bash

spark_master=spark:7077

docker exec spark ./bin/spark-submit \
    --master spark://${spark_master} \
    /apps/county_to_nearby_airports.py
