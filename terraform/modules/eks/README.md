# EKS module

This module creates the Kubernetes foundation for the AI platform:

- Amazon EKS control plane
- Cluster IAM role
- KMS encryption for Kubernetes secrets
- EKS managed node group
- Node IAM role
- EKS OIDC provider for IRSA
- Optional managed EKS add-ons

## Why this exists as a module

The VPC, EKS cluster, and application delivery layers should evolve
independently. Keeping EKS in its own module makes the platform easier to test,
reuse, and explain during interviews.

## Current baseline

The default node group is intentionally small and cost-aware. It is suitable for
portfolio development, not high-traffic production.

Production improvements can include:

- separate system and workload node groups
- Spot node groups for interruption-tolerant workloads
- Karpenter or Cluster Autoscaler
- private-only API endpoint access
- dedicated IAM role for the VPC CNI add-on
- stricter admin access management through EKS access entries
