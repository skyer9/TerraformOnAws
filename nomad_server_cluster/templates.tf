data "template_file" "user_data_nomad_server" {
  template = file("${path.module}/files/user-data-nomad-server.sh")

  vars = {
    server_count  = var.server_count
    region        = var.region
    retry_join    = var.retry_join
  }
}

data "aws_security_group" "server_lb" {
  name = "${var.stack_name}-server-lb"
}
