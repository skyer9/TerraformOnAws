resource "aws_elb" "nomad_client" {
  name               = "${var.stack_name}-nomad-client"
  availability_zones = var.availability_zones
  internal           = false
  # instances          = aws_autoscaling_group.nomad_client.*.id
  idle_timeout       = 360

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port            = 80
    lb_protocol        = "https"
    ssl_certificate_id = data.aws_acm_certificate.cert_skyer9_pe_kr.arn
  }

  listener {
    instance_port     = 4936
    instance_protocol = "http"
    lb_port            = 4936
    lb_protocol        = "https"
    ssl_certificate_id = data.aws_acm_certificate.cert_skyer9_pe_kr.arn
  }

  listener {
    instance_port     = 9090
    instance_protocol = "http"
    lb_port            = 9090
    lb_protocol        = "https"
    ssl_certificate_id = data.aws_acm_certificate.cert_skyer9_pe_kr.arn
  }

  listener {
    instance_port     = 3000
    instance_protocol = "http"
    lb_port            = 3000
    lb_protocol        = "https"
    ssl_certificate_id = data.aws_acm_certificate.cert_skyer9_pe_kr.arn
  }

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port            = 8000
    lb_protocol        = "https"
    ssl_certificate_id = data.aws_acm_certificate.cert_skyer9_pe_kr.arn
  }

  listener {
    instance_port     = 4646
    instance_protocol = "http"
    lb_port            = 4646
    lb_protocol        = "https"
    ssl_certificate_id = data.aws_acm_certificate.cert_skyer9_pe_kr.arn
  }

  health_check {
    healthy_threshold   = 8
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:4936"
    interval            = 30
  }

  security_groups = [aws_security_group.client_lb.id]
}
