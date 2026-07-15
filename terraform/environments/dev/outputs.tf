output "vpc_id" {
  description = "Development VPC identifier."
  value       = module.network.vpc_id
}

output "availability_zones" {
  description = "Availability Zones used by the development VPC."
  value       = module.network.availability_zones
}

output "public_subnet_ids" {
  description = "Subnets reserved for internet-facing load balancers."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Subnets used by EKS nodes and internal load balancers."
  value       = module.network.private_subnet_ids
}

output "eks_cluster_name" {
  description = "Development EKS cluster name."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Development EKS Kubernetes API endpoint."
  value       = module.eks.cluster_endpoint
}

output "eks_node_group_name" {
  description = "Default managed node group name."
  value       = module.eks.node_group_name
}

output "eks_oidc_provider_arn" {
  description = "OIDC provider ARN used by IRSA-enabled workloads."
  value       = module.eks.oidc_provider_arn
}

output "eks_oidc_issuer_hostpath" {
  description = "OIDC issuer host path used in IAM trust policies."
  value       = module.eks.oidc_issuer_hostpath
}

output "ecr_repository_name" {
  description = "AI inference container repository name."
  value       = module.workload_foundation.ecr_repository_name
}

output "ecr_repository_url" {
  description = "AI inference container repository URL."
  value       = module.workload_foundation.ecr_repository_url
}

output "ai_provider_secret_name" {
  description = "AI provider secret name; its value is managed outside Terraform."
  value       = module.workload_foundation.secret_name
}

output "ai_provider_secret_arn" {
  description = "AI provider secret ARN."
  value       = module.workload_foundation.secret_arn
}

output "application_secrets_kms_key_arn" {
  description = "KMS key ARN used to encrypt application Secrets Manager secrets."
  value       = module.workload_foundation.application_secrets_kms_key_arn
}

output "ai_inference_role_arn" {
  description = "IRSA role ARN for the AI inference service account."
  value       = module.workload_foundation.workload_role_arn
}

output "github_actions_ecr_publisher_role_arn" {
  description = "IAM role ARN to configure as GitHub environment secret AWS_ROLE_TO_ASSUME."
  value       = module.workload_foundation.github_actions_ecr_publisher_role_arn
}

output "aws_load_balancer_controller_role_arn" {
  description = "IRSA role ARN for AWS Load Balancer Controller."
  value       = module.platform_addons.aws_load_balancer_controller_role_arn
}

output "aws_load_balancer_controller_namespace" {
  description = "Namespace expected by the AWS Load Balancer Controller Helm release."
  value       = module.platform_addons.aws_load_balancer_controller_namespace
}

output "aws_load_balancer_controller_service_account" {
  description = "Service account expected by the AWS Load Balancer Controller Helm release."
  value       = module.platform_addons.aws_load_balancer_controller_service_account
}

output "aws_load_balancer_controller_helm_values" {
  description = "Non-secret Helm values needed when installing AWS Load Balancer Controller."
  value       = module.platform_addons.aws_load_balancer_controller_helm_values
}

output "external_secrets_role_arn" {
  description = "IRSA role ARN for External Secrets Operator."
  value       = module.platform_addons.external_secrets_role_arn
}

output "external_secrets_namespace" {
  description = "Namespace expected by the External Secrets Operator Helm release."
  value       = module.platform_addons.external_secrets_namespace
}

output "external_secrets_service_account" {
  description = "Service account expected by the External Secrets Operator Helm release."
  value       = module.platform_addons.external_secrets_service_account
}

output "external_secrets_helm_values" {
  description = "Non-secret Helm values needed when installing External Secrets Operator."
  value       = module.platform_addons.external_secrets_helm_values
}

output "application_log_group_name" {
  description = "CloudWatch Logs log group for application container logs."
  value       = module.platform_addons.application_log_group_name
}

output "aws_for_fluent_bit_role_arn" {
  description = "IRSA role ARN for AWS for Fluent Bit."
  value       = module.platform_addons.aws_for_fluent_bit_role_arn
}

output "aws_for_fluent_bit_namespace" {
  description = "Namespace expected by the AWS for Fluent Bit Helm release."
  value       = module.platform_addons.aws_for_fluent_bit_namespace
}

output "aws_for_fluent_bit_service_account" {
  description = "Service account expected by the AWS for Fluent Bit Helm release."
  value       = module.platform_addons.aws_for_fluent_bit_service_account
}

output "aws_for_fluent_bit_helm_values" {
  description = "Non-secret Helm values needed when installing AWS for Fluent Bit."
  value       = module.platform_addons.aws_for_fluent_bit_helm_values
}
