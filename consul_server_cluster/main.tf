provider "aws" {
  region  = var.region
}

resource "aws_instance" "consul_server" {
  ami                    = var.ami
  instance_type          = var.consul_server_instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.consul_lb.id]
  count                  = var.consul_server_count
  iam_instance_profile   = aws_iam_instance_profile.consul_server.name

  tags = {
    Name           = "${var.stack_name}-consul_server-${count.index + 1}"
    ConsulAutoJoin = "auto-join"
    OwnerName      = var.owner_name
    OwnerEmail     = var.owner_email
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.root_block_device_size
    delete_on_termination = "true"
  }

  user_data            = data.template_file.user_data_consul_server.rendered
}
