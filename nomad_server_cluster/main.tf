provider "aws" {
  region  = var.region
}

resource "aws_instance" "nomad_server" {
  ami                    = var.ami
  instance_type          = var.server_instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.server_lb.id]
  count                  = var.server_count
  iam_instance_profile   = aws_iam_instance_profile.nomad_server.name

  tags = {
    Name           = "${var.stack_name}-nomad_server-${count.index + 1}"
    ConsulAutoJoin = "auto-join"
    OwnerName      = var.owner_name
    OwnerEmail     = var.owner_email
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.root_block_device_size
    delete_on_termination = "true"
  }

  user_data            = data.template_file.user_data_nomad_server.rendered
}
