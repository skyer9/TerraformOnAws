resource "aws_elb" "nomad_client" {
  name               = "${var.stack_name}-nomad-client"
  availability_zones = var.availability_zones
  internal           = false
  # instances          = aws_autoscaling_group.nomad_client.*.id
  idle_timeout       = 360

  listener {
    instance_port     = 8400
    instance_protocol = "http"
    lb_port            = 8400
    lb_protocol        = "https"
    ssl_certificate_id = data.aws_acm_certificate.cert_skyer9_pe_kr.arn
  }

  listener {
    instance_port     = 8500
    instance_protocol = "http"
    lb_port            = 8500
    lb_protocol        = "https"
    ssl_certificate_id = data.aws_acm_certificate.cert_skyer9_pe_kr.arn
  }

  listener {
    instance_port     = 8600
    instance_protocol = "http"
    lb_port            = 8600
    lb_protocol        = "https"
    ssl_certificate_id = data.aws_acm_certificate.cert_skyer9_pe_kr.arn
  }

  health_check {
    healthy_threshold   = 8
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:8500"
    interval            = 30
  }

  security_groups = [aws_security_group.consul_lb.id]
}
