resource "aws_elb" "consul_server" {
  name               = "${var.stack_name}-consul-server"
  availability_zones = distinct(aws_instance.consul_server.*.availability_zone)
  internal           = false
  instances          = aws_instance.consul_server.*.id
  idle_timeout       = 360

  listener {
    instance_port     = 8500
    instance_protocol = "http"
    lb_port           = 8500
    lb_protocol       = "http"
  }
  security_groups = [data.aws_security_group.server_lb.id]
}
