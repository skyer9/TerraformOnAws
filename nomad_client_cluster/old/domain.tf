data "aws_route53_zone" "skyer9_pe_kr_zone" {
  name = "skyer9.pe.kr"
}

resource "aws_route53_record" "nomad_client" {
  zone_id = data.aws_route53_zone.skyer9_pe_kr_zone.zone_id
  name    = "nomad-client.skyer9.pe.kr"
  type    = "A"

  alias {
    name                   = aws_elb.nomad_client.dns_name
    zone_id                = aws_elb.nomad_client.zone_id
    evaluate_target_health = true
  }
}
