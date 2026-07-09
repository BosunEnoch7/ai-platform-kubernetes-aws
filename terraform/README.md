# Terraform infrastructure

Terraform owns AWS resources and foundational EKS integrations. It does not
deploy the inference application; Helm packages the application and Argo CD
reconciles it into the cluster.

## Layout

- `bootstrap/`: creates the protected S3 backend and KMS key used for Terraform
  state.
- `modules/`: reusable infrastructure components, introduced when the network
  and EKS design is approved.
- `environments/dev/`: development environment composition, introduced after
  bootstrap verification.
- `environments/prod/`: documented production differences; no production
  environment will be applied during early portfolio development.

Each environment has independent state. Terraform CLI workspaces are not used
as the primary environment boundary because directories make configuration,
state paths, permissions, and reviews more explicit.

## Authentication

Use short-lived AWS credentials through AWS CLI login, IAM Identity Center, or
an assumed role. Do not place access keys in Terraform variables, backend
configuration, `.tfvars` files, or GitHub secrets.

## Version policy

Root configurations accept compatible Terraform 1.x and AWS provider 6.x
releases. `.terraform.lock.hcl` records the provider version and checksums
actually selected by `terraform init`. Constraints express compatibility; the
lock file provides reproducibility.
