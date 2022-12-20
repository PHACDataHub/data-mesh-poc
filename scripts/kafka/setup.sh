#!/bin/bash

echo 'Creating volumes for zookeeper and broker(s) ...'

mkdir -p vol1/zk-data
mkdir -p vol2/zk-txn-logs
mkdir -p vol3/kafka-data

chown -R $(id -u):$(id -g) vol1/zk-data
chown -R $(id -u):$(id -g) vol2/zk-txn-logs
chown -R $(id -u):$(id -g) vol3/kafka-data

echo 'Volumes for zookeeper and broker(s) created ✅'

echo 'Creating folders for spooldir data ...'

mkdir -p data/error/ data/processed/ data/unprocessed/;

for item in counties airports arptoarp dailyc19
do
    cp data/csv/${item}.csv data/unprocessed/.;
done

chmod -R a+rw vol*
sudo chmod -R a+rw plugins
sudo chmod -R a+rw data

echo 'Folders for spooldir data created ✅'