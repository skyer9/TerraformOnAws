#!/bin/bash

set -e

sudo mkdir -p /ops
cd /ops/

sudo wget https://github.com/skyer9/TerraformOnAws/raw/main/files/setup.sh
sudo wget https://github.com/skyer9/TerraformOnAws/raw/main/files/net.sh
sudo wget https://github.com/skyer9/TerraformOnAws/raw/main/files/consul-client.hcl
sudo wget https://github.com/skyer9/TerraformOnAws/raw/main/files/consul.service
sudo wget https://github.com/skyer9/TerraformOnAws/raw/main/files/nomad-client.sh
sudo wget https://github.com/skyer9/TerraformOnAws/raw/main/files/nomad-client.hcl
sudo wget https://github.com/skyer9/TerraformOnAws/raw/main/files/nomad-client.service

sudo chmod +x /ops/setup.sh
sudo chmod +x /ops/net.sh
sudo chmod +x /ops/nomad-client.sh

sudo bash -c "/ops/nomad-client.sh \"${server_count}\" \"${retry_join}\" \"${access_key}\" \"${secret_access_key}\""
# rm -rf /ops/
