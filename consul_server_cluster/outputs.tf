output "consul_addr" {
  value = "http://${aws_elb.consul_server.dns_name}:8500"
}
