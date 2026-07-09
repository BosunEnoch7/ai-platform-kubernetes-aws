resource "aws_kms_key" "application_secrets" {
  description             = "Encrypts ${local.secret_name} in AWS Secrets Manager"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(local.tags, { Name = "${var.name}-application-secrets" })
}

resource "aws_kms_alias" "application_secrets" {
  name          = "alias/${var.name}-application-secrets"
  target_key_id = aws_kms_key.application_secrets.key_id
}

resource "aws_secretsmanager_secret" "ai_provider" {
  name                    = local.secret_name
  description             = "AI provider credentials consumed by the inference workload"
  kms_key_id              = aws_kms_key.application_secrets.arn
  recovery_window_in_days = var.secret_recovery_window_days

  tags = merge(local.tags, { Name = local.secret_name })
}

# No aws_secretsmanager_secret_version: values must not enter Terraform state.
