datacenter = "dc1"

data_dir = "/opt/nomad"
bind_addr  = "0.0.0.0"

advertise {
  http = "{{ GetPrivateIP }}"
  rpc  = "{{ GetPrivateIP }}"
  serf = "{{ GetPrivateIP }}"
}

server {
  enabled          = true
  bootstrap_expect = SERVER_COUNT
}

telemetry {
  publish_allocation_metrics = true
  publish_node_metrics       = true
  prometheus_metrics         = true
}
