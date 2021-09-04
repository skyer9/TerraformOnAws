provider "aws" {
  region  = var.region
}

resource "aws_iam_role" "consul_role" {
  name = "${var.stack_name}-consul_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances"
            ],
            "Resource": "*"
        }
    ]
}
EOF

  tags = {
    tag-key = "consul_role"
  }
}

resource "aws_iam_instance_profile" "consul_profile" {
  name = "${var.stack_name}-consul_profile"
  role = aws_iam_role.consul_role.name
}
