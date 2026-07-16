# Live evidence capture - July 16, 2026

This folder contains sanitized command-output evidence from a controlled AWS
deployment window.

## What was proven

- Terraform successfully reconciled the live AWS environment.
- Amazon EKS cluster was created for `ai-platform-kubernetes-aws-dev`.
- Managed node group was created with `t3.micro` nodes because the AWS account
  rejected `t3.medium` as not Free Tier eligible.
- Amazon ECR repository was created with immutable image tags and KMS
  encryption.
- IRSA roles and GitHub Actions OIDC ECR publisher role were created.
- Terraform reported: `No changes. Your infrastructure matches the configuration.`

## Evidence files

| File | Purpose |
|---|---|
| `terraform-plan.txt` | Terraform reconciliation proof showing no drift before teardown |
| `terraform-outputs.json` | Terraform outputs for EKS, ECR, IRSA, Secrets Manager, and CloudWatch |
| `eks-cluster.json` | EKS cluster status and tags during the live window |
| `eks-nodegroup.json` | Managed node group status, scaling config, and instance type |
| `ecr-repository.json` | ECR repository configuration |

## Known live-demo blocker

The application image was not pushed during this window because the workstation
had intermittent DNS/TLS timeouts reaching external container registries:

- Docker Hub base image pull timed out.
- AWS Public ECR fallback pull also timed out.
- ECR API was intermittently unreachable from the workstation.

The platform-side solution is already implemented in the repository:

- GitHub Actions container workflow: `.github/workflows/container.yml`
- Terraform-created GitHub OIDC publisher role:
  `github_actions_ecr_publisher_role_arn`

In a stable network window, the remaining evidence step is to run the GitHub
Actions container workflow or successfully build/push the image locally.

## Teardown status

After evidence capture, the live infrastructure was torn down to control cost.

Confirmed after teardown:

- no EKS clusters listed;
- no active NAT Gateways listed;
- no Elastic IPs listed;
- no load balancers listed.

KMS keys created during the live window are scheduled for deletion because AWS
does not allow immediate KMS key deletion.
