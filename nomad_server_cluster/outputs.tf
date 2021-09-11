output "nomad_addr" {
  value = "http://${aws_route53_record.nomad_server.name}:4646"
}
