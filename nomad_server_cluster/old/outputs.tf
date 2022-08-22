output "nomad_addr" {
  value = "https://${aws_route53_record.nomad_server.name}:4646"
}
