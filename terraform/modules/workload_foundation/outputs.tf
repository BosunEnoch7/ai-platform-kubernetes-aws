output "ecr_repository_name" {
  description = "Application ECR repository name."
  value       = aws_ecr_repository.application.name
}

output "ecr_repository_url" {
  description = "Application ECR repository URL."
  value       = aws_ecr_repository.application.repository_url
}

output "secret_name" {
  description = "AI provider secret name; no secret value is managed here."
  value       = aws_secretsmanager_secret.ai_provider.name
}

output "secret_arn" {
  description = "AI provider secret ARN."
  value       = aws_secretsmanager_secret.ai_provider.arn
}

output "application_secrets_kms_key_arn" {
  description = "KMS key ARN used to encrypt application Secrets Manager secrets."
  value       = aws_kms_key.application_secrets.arn
}

output "workload_role_arn" {
  description = "IRSA role ARN for the AI inference service account."
  value       = aws_iam_role.ai_inference.arn
}

output "github_actions_ecr_publisher_role_arn" {
  description = "IAM role ARN for GitHub Actions OIDC image publishing."
  value       = try(aws_iam_role.github_actions_ecr_publisher[0].arn, null)
}
