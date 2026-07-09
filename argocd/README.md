# Argo CD GitOps layer

This directory contains Argo CD manifests for reconciling Kubernetes platform
add-ons and application releases.

## Ownership boundary

Terraform owns AWS resources:

- VPC, subnets, route tables, NAT, endpoints;
- EKS cluster and node groups;
- IAM roles and policies;
- ECR repositories;
- Secrets Manager secret containers.

Argo CD owns Kubernetes resources:

- controller Helm releases;
- namespaces;
- workload Helm releases;
- app routing manifests;
- monitoring resources.

## Bootstrap order

1. Apply Terraform infrastructure.
2. Install Argo CD into the cluster.
3. Replace `REPLACE_WITH_GITHUB_USERNAME` with the GitHub owner that hosts this
   repository.
4. Replace placeholder AWS values in the add-on Applications.
5. Apply the platform add-ons Application.
6. Apply the AI inference application project and Application.

Argo CD is intentionally not installed by Terraform in this project. Keeping
Terraform and GitOps ownership separate makes drift easier to reason about.
