output "nomad_addr" {
  value = "http://${aws_elb.nomad_server.dns_name}:4646"
}

output "consul_addr" {
  value = "http://${aws_elb.nomad_server.dns_name}:8500"
}
