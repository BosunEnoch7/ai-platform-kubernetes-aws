locals {
  project_name = "ai-platform-kubernetes-aws"
  environment  = "dev"
  name_prefix  = "${local.project_name}-${local.environment}"

  common_tags = merge(
    {
      Project     = local.project_name
      Environment = local.environment
      ManagedBy   = "terraform"
      Owner       = "Olatubosun-Enoch-David"
    },
    var.additional_tags
  )
}
