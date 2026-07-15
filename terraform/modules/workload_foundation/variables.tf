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

variable "enable_github_actions_oidc_role" {
  description = "Create an IAM role that GitHub Actions can assume with OIDC to push images to ECR."
  type        = bool
  default     = true
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the image publisher role, formatted as owner/repo."
  type        = string
  default     = "BosunEnoch7/ai-platform-kubernetes-aws"

  validation {
    condition     = can(regex("^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$", var.github_repository))
    error_message = "github_repository must be formatted as owner/repo."
  }
}

variable "github_branch" {
  description = "Git branch allowed to assume the image publisher role."
  type        = string
  default     = "main"

  validation {
    condition     = can(regex("^[A-Za-z0-9._/-]+$", var.github_branch))
    error_message = "github_branch must be a valid branch name."
  }
}

variable "create_github_oidc_provider" {
  description = "Create the account-level GitHub Actions OIDC provider. Set false if the account already manages it elsewhere."
  type        = bool
  default     = true
}

variable "existing_github_oidc_provider_arn" {
  description = "Existing GitHub Actions OIDC provider ARN used when create_github_oidc_provider is false."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to supported resources."
  type        = map(string)
  default     = {}
}
