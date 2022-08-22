data "template_file" "user_data_nomad_client" {
  template = file("${path.module}/files/user-data-nomad-client.sh")

  vars = {
    server_count      = var.client_count
    retry_join        = var.retry_join
    access_key        = var.access_key
    secret_access_key = var.secret_access_key
    region            = var.region
  }
}

data "aws_security_group" "consul_lb" {
  name = "${var.stack_name}-consul-lb"
}

data "aws_security_group" "server_lb" {
  name = "${var.stack_name}-server-lb"
}
