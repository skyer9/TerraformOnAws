datacenter = "dc1"

data_dir = "/opt/nomad"

client {
  enabled = true
}

telemetry {
  publish_allocation_metrics = true
  publish_node_metrics       = true
  prometheus_metrics         = true
}
