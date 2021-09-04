provider "aws" {
  region  = var.region
}

resource "aws_instance" "nomad_client" {
  ami                    = var.ami
  instance_type          = var.server_instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [data.aws_security_group.primary.id]
  count                  = var.client_count
  iam_instance_profile   = "consul_profile"

  tags = {
    Name           = "${var.stack_name}-nomad_client"
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
