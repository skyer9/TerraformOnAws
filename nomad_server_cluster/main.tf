provider "aws" {
  region  = var.region
}

resource "aws_instance" "nomad_server" {
  ami                    = var.ami
  instance_type          = var.server_instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [data.aws_security_group.server_lb.id]
  count                  = var.server_count
  iam_instance_profile   = aws_iam_instance_profile.nomad_server.name

//  connection {
//    type        = "ssh"
//    host        = self.public_ip
//    user        = "ec2-user"
//    private_key = file("~/.ssh/${var.key_name}")
//  }
//
//  provisioner "file" {
//    source      = "${path.module}/../tls/consul/consul-agent-ca.pem"
//    destination = "~/consul-agent-ca.pem"
//  }
//
//  provisioner "file" {
//    source      = "${path.module}/../tls/consul/dc1-client-consul-0.pem"
//    destination = "~/dc1-client-consul-0.pem"
//  }
//
//  provisioner "file" {
//    source      = "${path.module}/../tls/consul/dc1-client-consul-0-key.pem"
//    destination = "~/dc1-client-consul-0-key.pem"
//  }

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
