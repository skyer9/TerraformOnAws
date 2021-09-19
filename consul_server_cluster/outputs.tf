output "consul_addr" {
  value = "http://${aws_route53_record.consul_server.name}:8500"
}
