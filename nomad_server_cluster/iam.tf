resource "aws_iam_instance_profile" "nomad_server" {
  name_prefix = var.stack_name
  role        = aws_iam_role.nomad_server.name
}

resource "aws_iam_role" "nomad_server" {
  name_prefix        = var.stack_name
  assume_role_policy = data.aws_iam_policy_document.nomad_server_assume.json
}

resource "aws_iam_role_policy" "nomad_server" {
  name   = "nomad-server"
  role   = aws_iam_role.nomad_server.id
  policy = data.aws_iam_policy_document.nomad_server.json
}

data "aws_iam_policy_document" "nomad_server_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "nomad_server" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "autoscaling:DescribeAutoScalingGroups",
    ]

    resources = ["*"]
  }
}
