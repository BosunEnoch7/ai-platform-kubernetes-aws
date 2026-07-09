variable "name" {
  description = "Name prefix for network resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment identifier."
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be valid IPv4 CIDR notation."
  }
}

variable "availability_zone_count" {
  description = "Number of Availability Zones used by the VPC."
  type        = number
  default     = 3

  validation {
    condition     = contains([2, 3], var.availability_zone_count)
    error_message = "availability_zone_count must be 2 or 3."
  }
}

variable "nat_gateway_mode" {
  description = "NAT topology: single for cost optimization or per_az for resilience."
  type        = string
  default     = "single"

  validation {
    condition     = contains(["single", "per_az"], var.nat_gateway_mode)
    error_message = "nat_gateway_mode must be single or per_az."
  }
}

variable "enable_interface_endpoints" {
  description = "Create private ECR API, ECR Docker, STS, and Logs endpoints."
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Send accepted and rejected VPC traffic metadata to CloudWatch Logs."
  type        = bool
  default     = true
}

variable "flow_log_retention_days" {
  description = "CloudWatch retention period for VPC Flow Logs."
  type        = number
  default     = 30

  validation {
    condition = contains(
      [1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365],
      var.flow_log_retention_days
    )
    error_message = "flow_log_retention_days must be a supported CloudWatch value."
  }
}

variable "tags" {
  description = "Additional non-sensitive tags."
  type        = map(string)
  default     = {}
}
