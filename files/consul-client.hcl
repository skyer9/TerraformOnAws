data_dir = "/opt/consul/data"
log_level = "INFO"

server = false

ports {
  http = 8500
  # https = 8501
}

service {
  name = "consul"
}
