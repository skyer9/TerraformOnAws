#!/bin/bash

set -e

sudo mkdir -p /ops
cd /ops/

sudo wget https://github.com/skyer9/TerraformOnAws/raw/main/files/setup.sh
sudo wget https://github.com/skyer9/TerraformOnAws/raw/main/files/net.sh
sudo wget https://github.com/skyer9/TerraformOnAws/raw/main/files/consul-server.sh
sudo wget https://github.com/skyer9/TerraformOnAws/raw/main/files/consul-server.hcl
sudo wget https://github.com/skyer9/TerraformOnAws/raw/main/files/consul.service

sudo chmod +x /ops/setup.sh
sudo chmod +x /ops/net.sh
sudo chmod +x /ops/consul-server.sh

sudo bash -c "/ops/consul-server.sh \"${server_count}\" \"${retry_join}\""
# rm -rf /ops/
