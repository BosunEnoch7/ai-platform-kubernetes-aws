resource "aws_cloudwatch_log_group" "application" {
  name              = local.application_log_group_name
  retention_in_days = var.application_log_retention_days

  tags = merge(local.tags, {
    Name = local.application_log_group_name
  })
}

data "aws_iam_policy_document" "aws_for_fluent_bit_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_issuer_hostpath}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_issuer_hostpath}:sub"
      values   = [local.aws_for_fluent_bit_subject]
    }
  }
}

resource "aws_iam_role" "aws_for_fluent_bit" {
  name               = local.aws_for_fluent_bit_role_name
  assume_role_policy = data.aws_iam_policy_document.aws_for_fluent_bit_assume_role.json

  tags = merge(local.tags, {
    Name = local.aws_for_fluent_bit_role_name
  })
}

data "aws_iam_policy_document" "aws_for_fluent_bit" {
  statement {
    sid    = "WriteApplicationContainerLogs"
    effect = "Allow"
    actions = [
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:CreateLogStream",
    ]
    resources = [
      "${aws_cloudwatch_log_group.application.arn}:*",
    ]
  }

  statement {
    sid    = "DescribeApplicationLogGroup"
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "aws_for_fluent_bit" {
  name        = "${local.aws_for_fluent_bit_role_name}-policy"
  description = "Allows AWS for Fluent Bit to write application container logs to CloudWatch Logs"
  policy      = data.aws_iam_policy_document.aws_for_fluent_bit.json
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "aws_for_fluent_bit" {
  role       = aws_iam_role.aws_for_fluent_bit.name
  policy_arn = aws_iam_policy.aws_for_fluent_bit.arn
}
