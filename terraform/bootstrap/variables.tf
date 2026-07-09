variable "aws_region" {
  description = "AWS region that stores the Terraform state infrastructure."
  type        = string
  default     = "eu-west-1"

  validation {
    condition     = can(regex("^[a-z]{2}(-[a-z]+)+-[0-9]+$", var.aws_region))
    error_message = "aws_region must be a valid AWS region identifier."
  }
}

variable "project_name" {
  description = "Stable project identifier used in names and tags."
  type        = string
  default     = "ai-platform-kubernetes-aws"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,62}$", var.project_name))
    error_message = "project_name must be 3-63 lowercase letters, digits, or hyphens."
  }
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state."
  type        = string

  validation {
    condition = (
      length(var.state_bucket_name) >= 3 &&
      length(var.state_bucket_name) <= 63 &&
      can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.state_bucket_name)) &&
      !can(regex("\\.\\.", var.state_bucket_name))
    )
    error_message = "state_bucket_name must satisfy Amazon S3 bucket naming rules."
  }
}

variable "noncurrent_state_retention_days" {
  description = "Days to retain noncurrent state object versions."
  type        = number
  default     = 90

  validation {
    condition     = var.noncurrent_state_retention_days >= 30
    error_message = "Retain noncurrent state versions for at least 30 days."
  }
}

variable "additional_tags" {
  description = "Additional non-sensitive tags applied to bootstrap resources."
  type        = map(string)
  default     = {}
}
