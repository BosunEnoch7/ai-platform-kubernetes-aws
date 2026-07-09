# Development environment

This root module composes the development network, EKS cluster, AI workload AWS
foundation, and shared platform add-on prerequisites.

## Defaults

- Region: `eu-west-1`
- VPC: `10.20.0.0/16`
- Availability Zones: three
- NAT gateways: one, to control portfolio cost
- S3 gateway endpoint: enabled
- Paid interface endpoints: disabled
- VPC Flow Logs: enabled with 30-day retention
- EKS nodes: one small managed node group in private subnets
- EKS API endpoint: public and private access enabled for development
- EKS secrets: encrypted with a customer-managed KMS key
- IRSA foundation: cluster OIDC provider enabled
- ECR: private, KMS-encrypted, immutable tags, scan on push
- Secrets Manager: encrypted secret container; value excluded from Terraform
- Workload identity: one service account can read only its AI provider secret
- Platform identity: AWS Load Balancer Controller IRSA role and IAM policy
- Application logs: CloudWatch Logs group with 30-day retention and Fluent Bit
  IRSA role

The single NAT gateway is not the production topology. Set
`nat_gateway_mode = "per_az"` for AZ-local egress at the cost of three NAT
gateways.

The public EKS API endpoint is convenient for development, but production
should restrict `cluster_public_access_cidrs` to trusted networks or move
toward private-only access with a controlled admin path.

## Initialize without touching AWS

```powershell
terraform init -backend=false
terraform fmt -check -recursive
terraform validate
```

## Initialize with remote state

After the bootstrap has been applied, copy `backend.hcl.example` to the ignored
`backend.hcl`, replace its placeholders, and run:

```powershell
terraform init -backend-config=backend.hcl
```

Planning and applying require authenticated AWS credentials and a separately
reviewed approval.
