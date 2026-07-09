variable "aws_region" {
  description = "AWS region for the development platform."
  type        = string
  default     = "eu-west-1"
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the development VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "nat_gateway_mode" {
  description = "single minimizes development cost; per_az improves resilience."
  type        = string
  default     = "single"
}

variable "enable_interface_endpoints" {
  description = "Enable paid interface endpoints after measuring NAT usage."
  type        = bool
  default     = false
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version. Null lets AWS use the current default; pin before production use."
  type        = string
  default     = null
}

variable "cluster_public_access_cidrs" {
  description = "CIDRs allowed to access the public EKS API endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_instance_types" {
  description = "Instance types for the default development node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_capacity_type" {
  description = "ON_DEMAND for stable demos; SPOT for lower-cost interruption-tolerant workloads."
  type        = string
  default     = "ON_DEMAND"
}

variable "node_desired_size" {
  description = "Desired worker node count for development."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum worker node count for development."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum worker node count for development."
  type        = number
  default     = 3
}

variable "kubernetes_namespace" {
  description = "Namespace used by the AI inference workload."
  type        = string
  default     = "ai-platform"
}

variable "kubernetes_service_account" {
  description = "IRSA-enabled service account used by the AI inference workload."
  type        = string
  default     = "ai-inference"
}

variable "additional_tags" {
  description = "Additional non-sensitive resource tags."
  type        = map(string)
  default     = {}
}
