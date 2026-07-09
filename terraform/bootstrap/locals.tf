locals {
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = "shared"
      ManagedBy   = "terraform"
      Component   = "terraform-state"
      Owner       = "Olatubosun-Enoch-David"
    },
    var.additional_tags
  )
}
