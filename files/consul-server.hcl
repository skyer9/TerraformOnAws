advertise_addr = "IP_ADDRESS"
bind_addr = "0.0.0.0"
bootstrap_expect = SERVER_COUNT
client_addr = "0.0.0.0"
data_dir = "/opt/consul/data"
log_level = "INFO"

server = true
ui_config {
  enabled = true
}

verify_incoming = true
verify_outgoing = true
# verify_server_hostname = true
ca_file = "/consul-agent-ca.pem"
cert_file = "/dc1-server-consul-0.pem"
key_file = "/dc1-server-consul-0-key.pem"

ports {
  http = 8500
  https = 8501
}

service {
  name = "consul"
}
