resource "aws_iam_instance_profile" "consul_server" {
  name_prefix = var.stack_name
  role        = aws_iam_role.consul_server.name
}

resource "aws_iam_role" "consul_server" {
  name_prefix        = var.stack_name
  assume_role_policy = data.aws_iam_policy_document.consul_server_assume.json
}

resource "aws_iam_role_policy" "consul_server" {
  name   = "nomad-server"
  role   = aws_iam_role.consul_server.id
  policy = data.aws_iam_policy_document.consul_server.json
}

data "aws_iam_policy_document" "consul_server_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "consul_server" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
    ]

    resources = ["*"]
  }
}
