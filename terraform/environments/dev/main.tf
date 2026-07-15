module "network" {
  source = "../../modules/network"

  name                       = local.name_prefix
  environment                = local.environment
  vpc_cidr                   = var.vpc_cidr
  availability_zone_count    = 3
  nat_gateway_mode           = var.nat_gateway_mode
  enable_interface_endpoints = var.enable_interface_endpoints
  enable_flow_logs           = true
  flow_log_retention_days    = 30
  tags                       = local.common_tags
}

module "eks" {
  source = "../../modules/eks"

  name                        = local.name_prefix
  environment                 = local.environment
  kubernetes_version          = var.kubernetes_version
  vpc_id                      = module.network.vpc_id
  private_subnet_ids          = module.network.private_subnet_ids
  cluster_public_access_cidrs = var.cluster_public_access_cidrs
  node_instance_types         = var.node_instance_types
  node_capacity_type          = var.node_capacity_type
  node_desired_size           = var.node_desired_size
  node_min_size               = var.node_min_size
  node_max_size               = var.node_max_size
  tags                        = local.common_tags
}

module "workload_foundation" {
  source = "../../modules/workload_foundation"

  name                              = local.name_prefix
  environment                       = local.environment
  oidc_provider_arn                 = module.eks.oidc_provider_arn
  oidc_issuer_hostpath              = module.eks.oidc_issuer_hostpath
  kubernetes_namespace              = var.kubernetes_namespace
  kubernetes_service_account        = var.kubernetes_service_account
  github_repository                 = var.github_repository
  github_branch                     = var.github_branch
  create_github_oidc_provider       = var.create_github_oidc_provider
  existing_github_oidc_provider_arn = var.existing_github_oidc_provider_arn
  tags                              = local.common_tags
}

module "platform_addons" {
  source = "../../modules/platform_addons"

  name                 = local.name_prefix
  environment          = local.environment
  cluster_name         = module.eks.cluster_name
  vpc_id               = module.network.vpc_id
  oidc_provider_arn    = module.eks.oidc_provider_arn
  oidc_issuer_hostpath = module.eks.oidc_issuer_hostpath
  external_secrets_allowed_secret_arns = [
    module.workload_foundation.secret_arn,
  ]
  external_secrets_kms_key_arns = [
    module.workload_foundation.application_secrets_kms_key_arn,
  ]
  tags = local.common_tags
}
