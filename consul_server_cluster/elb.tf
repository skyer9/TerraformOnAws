resource "aws_elb" "consul_server" {
  name               = "${var.stack_name}-consul-server"
  availability_zones = distinct(aws_instance.consul_server.*.availability_zone)
  internal           = false
  instances          = aws_instance.consul_server.*.id
  idle_timeout       = 360

  listener {
    instance_port     = 8400
    instance_protocol = "http"
    lb_port            = 8400
    lb_protocol        = "http"
  }

  listener {
    instance_port     = 8500
    instance_protocol = "http"
    lb_port            = 8500
    lb_protocol        = "http"
  }

  listener {
    instance_port     = 8600
    instance_protocol = "http"
    lb_port            = 8600
    lb_protocol        = "http"
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
