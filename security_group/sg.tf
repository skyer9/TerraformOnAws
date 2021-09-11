data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "consul_lb" {
  name   = "${var.stack_name}-consul-lb"
  vpc_id = data.aws_vpc.default.id

  # Consul HTTP API & UI.
  ingress {
    from_port   = 8300
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = var.my_ip
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.my_notebook_ip
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "consul_lb_consul_ingress" {
  type        = "ingress"
  from_port   = 8300
  to_port     = 8600
  protocol    = "tcp"
  security_group_id = aws_security_group.consul_lb.id
  source_security_group_id = aws_security_group.consul_lb.id
}

resource "aws_security_group_rule" "consul_lb_server_ingress" {
  type        = "ingress"
  from_port   = 8300
  to_port     = 8600
  protocol    = "tcp"
  security_group_id = aws_security_group.consul_lb.id
  source_security_group_id = aws_security_group.server_lb.id
}

resource "aws_security_group_rule" "consul_lb_client_ingress" {
  type        = "ingress"
  from_port   = 8300
  to_port     = 8600
  protocol    = "tcp"
  security_group_id = aws_security_group.consul_lb.id
  source_security_group_id = aws_security_group.client_lb.id
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
    security_groups = [aws_security_group.consul_lb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "server_lb_nomad_server_ingress" {
  type        = "ingress"
  from_port   = 4646
  to_port     = 4648
  protocol    = "tcp"
  security_group_id = aws_security_group.server_lb.id
  source_security_group_id = aws_security_group.server_lb.id
}

resource "aws_security_group_rule" "server_lb_nomad_client_ingress" {
  type        = "ingress"
  from_port   = 4646
  to_port     = 4648
  protocol    = "tcp"
  security_group_id = aws_security_group.server_lb.id
  source_security_group_id = aws_security_group.client_lb.id
}

resource "aws_security_group_rule" "server_lb_consul_client_ingress" {
  type        = "ingress"
  from_port   = 8300
  to_port     = 8600
  protocol    = "tcp"
  security_group_id = aws_security_group.server_lb.id
  source_security_group_id = aws_security_group.client_lb.id
}

resource "aws_security_group" "client_lb" {
  name   = "${var.stack_name}-client-lb"
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
    security_groups = [aws_security_group.server_lb.id]
  }

  # Consul HTTP API & UI.
  ingress {
    from_port   = 8300
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = var.my_ip
    security_groups = [
      aws_security_group.consul_lb.id,
      aws_security_group.server_lb.id
    ]
  }

  # Webapp HTTP.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowlist_ip
  }

  # Grafana metrics dashboard.
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = var.my_ip
  }

  # Prometheus dashboard.
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = var.my_ip
  }

  # haproxy
  ingress {
    from_port   = 4936
    to_port     = 4936
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
