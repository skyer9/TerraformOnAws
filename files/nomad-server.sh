#!/bin/bash

FILES_DIR=/ops

$FILES_DIR/setup.sh

source $FILES_DIR/net.sh
set -e

CONSUL_CONFIG_DIR=/etc/consul.d
NOMAD_CONFIG_DIR=/etc/nomad.d

# Wait for network
sleep 15

SERVER_COUNT=$1
RETRY_JOIN=$2

# Consul

sed -i "s/RETRY_JOIN/$RETRY_JOIN/g" $FILES_DIR/consul-client.hcl
sudo cp $FILES_DIR/consul-client.hcl $CONSUL_CONFIG_DIR/consul.hcl
sudo cp $FILES_DIR/consul.service /etc/systemd/system/consul.service

# Nomad

sed -i "s/SERVER_COUNT/$SERVER_COUNT/g" $FILES_DIR/nomad-server.hcl
sudo cp $FILES_DIR/nomad-server.hcl $NOMAD_CONFIG_DIR/nomad.hcl
sudo cp $FILES_DIR/nomad.service /etc/systemd/system/nomad.service

sudo systemctl daemon-reload

sudo systemctl enable consul
sudo systemctl start consul.service
sudo systemctl enable nomad
sudo systemctl start nomad.service
