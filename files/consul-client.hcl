data_dir = "/opt/consul/data"
log_level = "INFO"

server = false

## verify_incoming = true
## verify_outgoing = true
## # verify_server_hostname = true
## ca_file = "/home/ec2-user/consul-agent-ca.pem"
## cert_file = "/home/ec2-user/dc1-client-consul-0.pem"
## key_file = "/home/ec2-user/dc1-client-consul-0-key.pem"
##
## ports {
##   http = 8500
##   https = 8501
## }

service {
  name = "consul"
}
