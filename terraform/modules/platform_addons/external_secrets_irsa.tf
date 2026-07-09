data "aws_iam_policy_document" "external_secrets_assume_role" {
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
      values   = [local.external_secrets_subject]
    }
  }
}

resource "aws_iam_role" "external_secrets" {
  name               = local.external_secrets_role_name
  assume_role_policy = data.aws_iam_policy_document.external_secrets_assume_role.json

  tags = merge(local.tags, {
    Name = local.external_secrets_role_name
  })
}

data "aws_iam_policy_document" "external_secrets" {
  statement {
    sid    = "ReadApprovedSecretsManagerSecrets"
    effect = "Allow"
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
    ]
    resources = var.external_secrets_allowed_secret_arns
  }

  dynamic "statement" {
    for_each = length(var.external_secrets_kms_key_arns) > 0 ? [1] : []

    content {
      sid       = "DecryptApprovedSecretsThroughSecretsManager"
      effect    = "Allow"
      actions   = ["kms:Decrypt"]
      resources = var.external_secrets_kms_key_arns

      condition {
        test     = "StringEquals"
        variable = "kms:ViaService"
        values   = ["secretsmanager.${data.aws_region.current.region}.amazonaws.com"]
      }
    }
  }
}

resource "aws_iam_policy" "external_secrets" {
  name        = "${local.external_secrets_role_name}-policy"
  description = "Allows External Secrets Operator to read approved Secrets Manager secrets"
  policy      = data.aws_iam_policy_document.external_secrets.json
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "external_secrets" {
  role       = aws_iam_role.external_secrets.name
  policy_arn = aws_iam_policy.external_secrets.arn
}
