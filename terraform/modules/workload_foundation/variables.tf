variable "name" {
  description = "Name prefix shared by application foundation resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "oidc_provider_arn" {
  description = "EKS OIDC provider ARN used as the IRSA trust principal."
  type        = string
}

variable "oidc_issuer_hostpath" {
  description = "EKS OIDC issuer without the https:// prefix."
  type        = string
}

variable "kubernetes_namespace" {
  description = "Namespace containing the AI inference service account."
  type        = string
  default     = "ai-platform"
}

variable "kubernetes_service_account" {
  description = "Service account allowed to assume the AI workload IAM role."
  type        = string
  default     = "ai-inference"
}

variable "retained_image_count" {
  description = "Maximum number of images retained in ECR."
  type        = number
  default     = 20

  validation {
    condition     = var.retained_image_count > 0
    error_message = "retained_image_count must be greater than zero."
  }
}

variable "untagged_image_retention_days" {
  description = "Days an untagged image remains in ECR."
  type        = number
  default     = 7

  validation {
    condition     = var.untagged_image_retention_days > 0
    error_message = "untagged_image_retention_days must be greater than zero."
  }
}

variable "secret_recovery_window_days" {
  description = "Recovery window for a deleted application secret."
  type        = number
  default     = 7

  validation {
    condition     = var.secret_recovery_window_days >= 7 && var.secret_recovery_window_days <= 30
    error_message = "secret_recovery_window_days must be between 7 and 30."
  }
}

variable "tags" {
  description = "Tags applied to supported resources."
  type        = map(string)
  default     = {}
}
