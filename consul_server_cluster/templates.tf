data "template_file" "user_data_consul_server" {
  template = file("${path.module}/files/user-data-consul-server.sh")

  vars = {
    server_count  = var.consul_server_count
    region        = var.region
    retry_join    = var.retry_join
  }
}

data "aws_security_group" "primary" {
  name = "${var.stack_name}-primary"
}

data "aws_iam_instance_profile" "consul_profile" {
  name = "${var.stack_name}-consul_profile"
}
