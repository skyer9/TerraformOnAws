resource "aws_acm_certificate" "cert_nomad_server_skyer9_pe_kr" {
  domain_name       = "nomad.server.skyer9.pe.kr"
  validation_method = "DNS"

  tags = {
    Environment = "nomad.server.skyer9.pe.kr"
  }

  lifecycle {
    create_before_destroy = true
  }
}
