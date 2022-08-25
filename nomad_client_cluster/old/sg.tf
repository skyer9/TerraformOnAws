data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group_rule" "client_to_consul_ingress" {
  type        = "ingress"
  from_port   = 1
  to_port     = 65535
  protocol    = "tcp"
  security_group_id = data.aws_security_group.consul_lb.id
  source_security_group_id = aws_security_group.client_lb.id
}

resource "aws_security_group_rule" "client_to_server_ingress" {
  type        = "ingress"
  from_port   = 1
  to_port     = 65535
  protocol    = "tcp"
  security_group_id = data.aws_security_group.server_lb.id
  source_security_group_id = aws_security_group.client_lb.id
}

resource "aws_security_group" "client_lb" {
  name   = "${var.stack_name}-client-lb"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 1
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = var.my_notebook_ip
  }

  ingress {
    from_port   = 1
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = var.my_ip
  }

  # Webapp HTTP.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowlist_ip
  }

  # github webhook
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["192.30.252.0/22"]
  }

  # github webhook
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["185.199.108.0/22"]
  }

  # github webhook
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["140.82.112.0/20"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "consul_to_client_ingress" {
  type        = "ingress"
  from_port   = 1
  to_port     = 65535
  protocol    = "tcp"
  security_group_id = aws_security_group.client_lb.id
  source_security_group_id = data.aws_security_group.consul_lb.id
}

resource "aws_security_group_rule" "server_to_client_ingress" {
  type        = "ingress"
  from_port   = 1
  to_port     = 65535
  protocol    = "tcp"
  security_group_id = aws_security_group.client_lb.id
  source_security_group_id = data.aws_security_group.server_lb.id
}

resource "aws_security_group_rule" "client_to_client_ingress" {
  type        = "ingress"
  from_port   = 1
  to_port     = 65535
  protocol    = "tcp"
  security_group_id = aws_security_group.client_lb.id
  source_security_group_id = aws_security_group.client_lb.id
}
