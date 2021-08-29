#!/bin/bash

set -e

sudo chmod +x /ops/scripts/consul-server.sh
sudo bash -c "/ops/scripts/consul-server.sh \"${server_count}\" \"${retry_join}\""
rm -rf /ops/
