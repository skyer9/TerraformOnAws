provider "aws" {
  region  = var.region
}

resource "aws_iam_instance_profile" "consul_profile" {
  name = "${var.stack_name}-consul_profile"
  role = "DescribeInstancesRole"
}
