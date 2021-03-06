#!/bin/bash

set -e

sudo mkdir -p /ops
cd /ops/

sudo wget https://github.com/skyer9/TerraformOnAws/raw/main/files/setup.sh
sudo wget https://github.com/skyer9/TerraformOnAws/raw/main/files/net.sh
sudo wget https://github.com/skyer9/TerraformOnAws/raw/main/files/consul-client.hcl
sudo wget https://github.com/skyer9/TerraformOnAws/raw/main/files/consul.service
sudo wget https://github.com/skyer9/TerraformOnAws/raw/main/files/nomad-server.sh
sudo wget https://github.com/skyer9/TerraformOnAws/raw/main/files/nomad-server.hcl
sudo wget https://github.com/skyer9/TerraformOnAws/raw/main/files/nomad-server.service

sudo chmod +x /ops/setup.sh
sudo chmod +x /ops/net.sh
sudo chmod +x /ops/nomad-server.sh

sudo bash -c "/ops/nomad-server.sh \"${server_count}\" \"${retry_join}\""
# rm -rf /ops/
