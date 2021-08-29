#!/bin/bash

FILESDIR=/ops

$FILESDIR/setup.sh

source $FILESDIR/net.sh
set -e

CONSULCONFIGDIR=/etc/consul.d

# Wait for network
sleep 15

IP_ADDRESS=$(net_getDefaultRouteAddress)
SERVER_COUNT=$1
RETRY_JOIN=$2

# Consul

sed -i "s/IP_ADDRESS/$IP_ADDRESS/g" $FILESDIR/consul-server.hcl
sed -i "s/SERVER_COUNT/$SERVER_COUNT/g" $FILESDIR/consul-server.hcl
sed -i "s/RETRY_JOIN/$RETRY_JOIN/g" $FILESDIR/consul-server.hcl
sudo cp $FILESDIR/consul-server.hcl $CONSULCONFIGDIR/consul.hcl
sudo cp $FILESDIR/consul.service /etc/systemd/system/consul.service

sudo systemctl daemon-reload
sudo systemctl enable consul
sudo systemctl start consul.service
