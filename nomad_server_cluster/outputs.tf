output "nomad_addr" {
  value = "http://${aws_elb.nomad_server.dns_name}:4646"
}
