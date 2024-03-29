provider "aws" {
  region  = var.region
}

resource "aws_instance" "nomad_client" {
  ami                    = var.ami
  instance_type          = var.client_instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.client_lb.id]
  count                  = var.client_count
  iam_instance_profile   = aws_iam_instance_profile.nomad_client.name

  tags = {
    Name           = "${var.stack_name}-nomad_client-${count.index + 1}"
    ConsulAutoJoin = "auto-join"
    OwnerName      = var.owner_name
    OwnerEmail     = var.owner_email
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.root_block_device_size
    delete_on_termination = "true"
  }

  user_data            = data.template_file.user_data_nomad_client.rendered
}
