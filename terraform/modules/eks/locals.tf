locals {
  cluster_name    = var.name
  node_group_name = "${var.name}-default"

  oidc_issuer_hostpath = replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")

  tags = merge(
    var.tags,
    {
      Module      = "eks"
      Environment = var.environment
    }
  )
}
