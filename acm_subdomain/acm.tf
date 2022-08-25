resource "aws_acm_certificate" "cert_nomad_client_skyer9_pe_kr" {
  domain_name       = "nomad-client.skyer9.pe.kr"
  validation_method = "DNS"

  tags = {
    Environment = "nomad-client.skyer9.pe.kr"
  }

  lifecycle {
    create_before_destroy = true
  }
}