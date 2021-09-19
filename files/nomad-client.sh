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

sed -i "s/RETRY_JOIN/$RETRY_JOIN/g" $FILES_DIR/consul.service
sudo cp $FILES_DIR/consul-client.hcl $CONSUL_CONFIG_DIR/consul.hcl
sudo cp $FILES_DIR/consul.service /etc/systemd/system/consul.service

# Nomad

sudo mkdir -p /var/log/nomad

sudo mkdir -p /opt/nomad-volumes/grafana
sudo chown 472:472 /opt/nomad-volumes/grafana
sudo mkdir -p /opt/nomad-volumes/jenkins_home
sudo chown 1000:1000 /opt/nomad-volumes/jenkins_home

sed -i "s/SERVER_COUNT/$SERVER_COUNT/g" $FILES_DIR/nomad-client.hcl
sudo cp $FILES_DIR/nomad-client.hcl $NOMAD_CONFIG_DIR/nomad.hcl
sudo cp $FILES_DIR/nomad-client.service /etc/systemd/system/nomad.service

sudo systemctl daemon-reload

sudo systemctl enable consul
sudo systemctl start consul.service
sudo systemctl enable nomad
sudo systemctl start nomad.service

# Docker

sudo yum install docker -y
sudo systemctl enable docker.service
sudo service docker start

# docker-credential-ecr-login

wget https://amazon-ecr-credential-helper-releases.s3.us-east-2.amazonaws.com/0.5.0/linux-amd64/docker-credential-ecr-login
sudo chown root:root docker-credential-ecr-login
sudo chmod 777 docker-credential-ecr-login
sudo mv docker-credential-ecr-login /usr/local/bin/
