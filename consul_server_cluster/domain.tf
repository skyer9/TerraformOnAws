data "aws_route53_zone" "skyer9_pe_kr_zone" {
  name = "skyer9.pe.kr"
}

resource "aws_route53_record" "consul_server" {
  zone_id = data.aws_route53_zone.skyer9_pe_kr_zone.zone_id
  name    = "consul-server.skyer9.pe.kr"
  type    = "A"

  records = [aws_instance.consul_server.public_ip]
}
