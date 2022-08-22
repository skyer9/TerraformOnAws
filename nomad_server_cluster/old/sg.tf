data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group_rule" "server_to_consul_ingress" {
  type        = "ingress"
  from_port   = 1
  to_port     = 65535
  protocol    = "tcp"
  security_group_id = data.aws_security_group.consul_lb.id
  source_security_group_id = aws_security_group.server_lb.id
}

resource "aws_security_group" "server_lb" {
  name   = "${var.stack_name}-server-lb"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.my_notebook_ip
  }

  # Nomad HTTP API & UI.
  ingress {
    from_port   = 4646
    to_port     = 4648
    protocol    = "tcp"
    cidr_blocks = var.my_ip
  }

  # Consul HTTP API & UI.
  ingress {
    from_port   = 8300
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = var.my_ip
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "consul_to_server_ingress" {
  type        = "ingress"
  from_port   = 1
  to_port     = 65535
  protocol    = "tcp"
  security_group_id = aws_security_group.server_lb.id
  source_security_group_id = data.aws_security_group.consul_lb.id
}

resource "aws_security_group_rule" "server_to_server_ingress" {
  type        = "ingress"
  from_port   = 1
  to_port     = 65535
  protocol    = "tcp"
  security_group_id = aws_security_group.server_lb.id
  source_security_group_id = aws_security_group.server_lb.id
}
