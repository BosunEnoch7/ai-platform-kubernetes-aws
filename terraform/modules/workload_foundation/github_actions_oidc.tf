resource "aws_iam_openid_connect_provider" "github_actions" {
  count = var.enable_github_actions_oidc_role && var.create_github_oidc_provider ? 1 : 0

  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
  ]

  tags = merge(local.tags, { Name = "${var.name}-github-actions-oidc" })
}

locals {
  github_oidc_provider_arn = var.create_github_oidc_provider ? try(aws_iam_openid_connect_provider.github_actions[0].arn, null) : var.existing_github_oidc_provider_arn
  github_actions_role_name = "${var.name}-github-actions-ecr-publisher"
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  count = var.enable_github_actions_oidc_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.github_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repository}:ref:refs/heads/${var.github_branch}"]
    }
  }
}

resource "aws_iam_role" "github_actions_ecr_publisher" {
  count = var.enable_github_actions_oidc_role ? 1 : 0

  name               = local.github_actions_role_name
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role[0].json
  tags               = merge(local.tags, { Name = local.github_actions_role_name })
}

data "aws_iam_policy_document" "github_actions_ecr_publish" {
  count = var.enable_github_actions_oidc_role ? 1 : 0

  statement {
    sid       = "AuthenticateToECR"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "PushOnlyToApplicationRepository"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = [aws_ecr_repository.application.arn]
  }
}

resource "aws_iam_policy" "github_actions_ecr_publish" {
  count = var.enable_github_actions_oidc_role ? 1 : 0

  name        = "${local.github_actions_role_name}-policy"
  description = "Allows GitHub Actions to push immutable AI inference images to the application ECR repository"
  policy      = data.aws_iam_policy_document.github_actions_ecr_publish[0].json
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr_publish" {
  count = var.enable_github_actions_oidc_role ? 1 : 0

  role       = aws_iam_role.github_actions_ecr_publisher[0].name
  policy_arn = aws_iam_policy.github_actions_ecr_publish[0].arn
}
