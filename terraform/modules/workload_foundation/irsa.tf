data "aws_region" "current" {}

data "aws_iam_policy_document" "assume_role" {
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
      values   = ["system:serviceaccount:${var.kubernetes_namespace}:${var.kubernetes_service_account}"]
    }
  }
}

resource "aws_iam_role" "ai_inference" {
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = merge(local.tags, { Name = local.role_name })
}

data "aws_iam_policy_document" "ai_inference" {
  statement {
    sid       = "ReadOnlyTheAIProviderSecret"
    effect    = "Allow"
    actions   = ["secretsmanager:DescribeSecret", "secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.ai_provider.arn]
  }

  statement {
    sid       = "DecryptOnlyThroughSecretsManager"
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [aws_kms_key.application_secrets.arn]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["secretsmanager.${data.aws_region.current.region}.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "ai_inference" {
  name        = "${local.role_name}-secrets"
  description = "Allows the AI inference workload to read only its provider secret"
  policy      = data.aws_iam_policy_document.ai_inference.json
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "ai_inference" {
  role       = aws_iam_role.ai_inference.name
  policy_arn = aws_iam_policy.ai_inference.arn
}
