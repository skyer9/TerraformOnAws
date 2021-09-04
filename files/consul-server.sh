#!/bin/bash

FILES_DIR=/ops

$FILES_DIR/setup.sh

source $FILES_DIR/net.sh
set -e

CONSUL_CONFIG_DIR=/etc/consul.d

# Wait for network
sleep 15

IP_ADDRESS=$(net_getDefaultRouteAddress)
SERVER_COUNT=$1
RETRY_JOIN=$2

# Consul

sed -i "s/IP_ADDRESS/$IP_ADDRESS/g" $FILES_DIR/consul-server.hcl
sed -i "s/SERVER_COUNT/$SERVER_COUNT/g" $FILES_DIR/consul-server.hcl
sed -i "s/RETRY_JOIN/$RETRY_JOIN/g" $FILES_DIR/consul-server.hcl
sudo cp $FILES_DIR/consul-server.hcl $CONSUL_CONFIG_DIR/consul.hcl
sudo cp $FILES_DIR/consul.service /etc/systemd/system/consul.service

sudo systemctl daemon-reload
sudo systemctl enable consul
sudo systemctl start consul.service
