resource "aws_acm_certificate" "cert_skyer9_pe_kr" {
  domain_name       = "skyer9.pe.kr"
  subject_alternative_names = ["*.skyer9.pe.kr"]
  validation_method = "DNS"

  tags = {
    Environment = "*.skyer9.pe.kr"
  }

  lifecycle {
    create_before_destroy = true
  }
}
