provider "aws" {
  region  = var.region
}

resource "aws_iam_instance_profile" "consul_profile" {
  name = "${var.stack_name}-consul_profile"
  role = "DescribeInstancesRole"
}

resource "aws_iam_role" "role" {
  name = "test_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow"
        },
        {
            "Effect": "Allow",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Action": [
                "ec2:DescribeInstances"
            ]
        }
    ]
}
EOF
}
