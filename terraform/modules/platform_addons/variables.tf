variable "name" {
  description = "Project/environment name prefix used for platform add-on resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name that platform add-ons will target."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster and load balancers run."
  type        = string
}

variable "oidc_provider_arn" {
  description = "EKS OIDC provider ARN used as the IRSA trust principal."
  type        = string
}

variable "oidc_issuer_hostpath" {
  description = "EKS OIDC issuer without https://, used in IRSA trust policy conditions."
  type        = string
}

variable "aws_load_balancer_controller_namespace" {
  description = "Namespace for the AWS Load Balancer Controller service account."
  type        = string
  default     = "kube-system"
}

variable "aws_load_balancer_controller_service_account" {
  description = "Service account name used by AWS Load Balancer Controller."
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "external_secrets_namespace" {
  description = "Namespace for External Secrets Operator."
  type        = string
  default     = "external-secrets"
}

variable "external_secrets_service_account" {
  description = "Service account name used by External Secrets Operator."
  type        = string
  default     = "external-secrets"
}

variable "external_secrets_allowed_secret_arns" {
  description = "Secrets Manager ARNs External Secrets Operator may read."
  type        = list(string)
  default     = []
}

variable "external_secrets_kms_key_arns" {
  description = "KMS key ARNs External Secrets Operator may decrypt through Secrets Manager."
  type        = list(string)
  default     = []
}

variable "aws_for_fluent_bit_namespace" {
  description = "Namespace for AWS for Fluent Bit."
  type        = string
  default     = "amazon-cloudwatch"
}

variable "aws_for_fluent_bit_service_account" {
  description = "Service account name used by AWS for Fluent Bit."
  type        = string
  default     = "aws-for-fluent-bit"
}

variable "application_log_retention_days" {
  description = "Retention in days for application container logs in CloudWatch Logs."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Common non-sensitive tags applied to created AWS resources."
  type        = map(string)
  default     = {}
}
