variable "name" {
  description = "Base name for EKS resources."
  type        = string
}

variable "environment" {
  description = "Environment name, such as dev, staging, or prod."
  type        = string
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version. Null lets AWS use the current default, but production should pin a supported version."
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC where EKS worker nodes run."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for managed node groups."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "EKS should use at least two private subnets for availability."
  }
}

variable "cluster_endpoint_public_access" {
  description = "Whether the EKS API endpoint is reachable from the public internet."
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Whether the EKS API endpoint is reachable from inside the VPC."
  type        = bool
  default     = true
}

variable "cluster_public_access_cidrs" {
  description = "CIDR ranges allowed to reach the public EKS API endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_log_types" {
  description = "EKS control plane log types sent to CloudWatch Logs."
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "node_instance_types" {
  description = "EC2 instance types for the default managed node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_capacity_type" {
  description = "Capacity type for the default node group: ON_DEMAND or SPOT."
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "node_capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "node_desired_size" {
  description = "Desired number of worker nodes."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 3
}

variable "node_disk_size_gb" {
  description = "Root volume size for worker nodes in GiB."
  type        = number
  default     = 30
}

variable "managed_addons" {
  description = "Managed EKS add-ons installed after cluster creation."
  type        = set(string)
  default     = ["vpc-cni", "kube-proxy", "coredns", "eks-pod-identity-agent"]
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
