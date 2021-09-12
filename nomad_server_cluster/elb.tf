resource "aws_elb" "nomad_server" {
  name               = "${var.stack_name}-nomad-server"
  availability_zones = distinct(aws_instance.nomad_server.*.availability_zone)
  internal           = false
  instances          = aws_instance.nomad_server.*.id
  idle_timeout       = 360

  listener {
    instance_port     = 4646
    instance_protocol = "http"
    lb_port            = 4646
    lb_protocol        = "https"
    ssl_certificate_id = aws_acm_certificate.cert_skyer9_pe_kr.arn
  }

  security_groups = [data.aws_security_group.server_lb.id]
}
