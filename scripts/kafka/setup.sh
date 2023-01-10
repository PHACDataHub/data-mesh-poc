#!/bin/bash

CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)
OSTYPE=$(uname -s)

if [[ $OSTYPE == 'Linux' ]]; then
    echo 'Add docker user to my group ...'
    docker_user=root
    sudo usermod -a -G $CURRENT_GID "${docker_user}"
    echo 'Docker user added to my group ✅'
    echo ''
fi

echo 'Creating volumes for zookeeper and broker(s) ...'
for item in vol1/zk-data vol2/zk-txn-logs vol3/kafka-data
do
    mkdir -p $item;
    sudo chown -R $CURRENT_UID $item;
    sudo chgrp -R $CURRENT_GID $item;
    sudo chmod -R u+rwX,g+rX,o+wrx $item;
    echo $item 'volume is created.'
done
echo 'Volumes for zookeeper and broker(s) created ✅'
echo ''

echo 'Creating folders for spooldir data ...'
for item in data/error data/processed data/unprocessed
do
    mkdir -p $item;
    sudo chown -R $CURRENT_UID $item;
    sudo chgrp -R $CURRENT_GID $item;
    sudo chmod -R u+rwX,g+rX,o+wrx $item;
    echo $item 'folder is created.'
done
echo 'Folders for spooldir data created ✅'
echo ''

echo 'Copying data into for spooldir ...'
cd data; tar xzvf data.tar.gz; cd ..;
for item in counties airports arptoarp dailyc19
do
    cp data/csv/${item}.csv data/unprocessed/.;
    echo data/csv/${item}.csv 'is copied.'
done
echo 'Folders for spooldir data created ✅'
echo ''

echo 'Setting permissions for plugins and data folders ...'
for item in data kafka/plugins
do
    sudo chown -R $CURRENT_UID $item;
    sudo chgrp -R $CURRENT_GID $item;
    sudo chmod -R u+rwX,g+rX,o+wrx $item;
    echo $item 'folder permissions are set.'
done
echo 'Permissions for data & plugins folders set ✅'