# Production-inspired deployment guide

This guide describes the intended deployment order for the AI platform on
Amazon EKS.

It is written as an operator guide. Do not copy/paste commands into a real AWS
account without reviewing cost, IAM, and networking assumptions.

## Deployment principle

Each tool owns a clear layer:

| Layer | Tool | Responsibility |
|---|---|---|
| AWS foundation | Terraform | VPC, EKS, ECR, IAM, Secrets Manager, CloudWatch Logs |
| Container artifact | GitHub Actions | Test, build, and push immutable image to ECR |
| Cluster add-ons | Argo CD + Helm | Controllers, monitoring, logging, secrets operator |
| Application | Argo CD + Helm | FastAPI AI inference workload |

## Prerequisites

- AWS CLI authenticated to the target account.
- Terraform installed.
- kubectl installed.
- Helm installed.
- GitHub repository created.
- Argo CD CLI optional but useful.
- An AWS budget configured before applying infrastructure.

## 1. Bootstrap Terraform state

Review the bootstrap configuration:

```powershell
terraform -chdir=terraform/bootstrap init -backend=false
terraform -chdir=terraform/bootstrap validate
terraform -chdir=terraform/bootstrap plan
```

After review, apply the bootstrap stack:

```powershell
terraform -chdir=terraform/bootstrap apply
```

Copy `backend.hcl.example` files to ignored `backend.hcl` files and fill in the
created S3 backend values.

## 2. Deploy AWS and EKS foundation

Initialize the dev environment with remote state:

```powershell
terraform -chdir=terraform/environments/dev init -backend-config=backend.hcl
terraform -chdir=terraform/environments/dev plan
```

Apply only after reviewing:

```powershell
terraform -chdir=terraform/environments/dev apply
```

Important outputs:

- `eks_cluster_name`
- `ecr_repository_name`
- `ecr_repository_url`
- `ai_inference_role_arn`
- `aws_load_balancer_controller_role_arn`
- `external_secrets_role_arn`
- `aws_for_fluent_bit_role_arn`
- `application_log_group_name`

## 3. Configure kubectl

```powershell
aws eks update-kubeconfig `
  --region eu-west-1 `
  --name ai-platform-kubernetes-aws-dev
```

Verify access:

```powershell
kubectl get nodes
kubectl get ns
```

## 4. Insert secret values into AWS Secrets Manager

Terraform creates the secret container, not the secret value.

```powershell
aws secretsmanager put-secret-value `
  --secret-id ai-platform-kubernetes-aws-dev/ai-provider `
  --secret-string '{ "api_key": "replace-with-real-value" }'
```

Never commit real secret values to Git.

## 5. Configure GitHub Actions

Create GitHub environment:

```text
dev
```

Add environment secret:

```text
AWS_ROLE_TO_ASSUME=<GitHub Actions deployment role ARN>
```

Add environment variables:

```text
AWS_REGION=eu-west-1
ECR_REPOSITORY=<terraform output ecr_repository_name>
```

## 6. Build and push the container image

Push to `main` or run the `Container Image` workflow manually.

The workflow pushes:

```text
<ecr_repository_url>:<git-sha>
```

Record the image tag. It is used by Argo CD.

## 7. Install Argo CD

Install Argo CD using your preferred bootstrap path.

Example:

```powershell
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

For production, pin the Argo CD manifest version instead of using `stable`.

## 8. Replace GitOps placeholders

Before applying Argo CD manifests, replace:

- `REPLACE_WITH_GITHUB_USERNAME`
- placeholder AWS account IDs
- placeholder IRSA role ARNs
- `vpc-replace-with-terraform-output`
- `replace-with-commit-sha`
- `REPLACE_WITH_PINNED_KUBE_PROMETHEUS_STACK_VERSION`

Values should come from Terraform outputs and CI results.

## 9. Apply Argo CD projects

```powershell
kubectl apply -f argocd/projects/platform.yaml
kubectl apply -f argocd/projects/ai-platform.yaml
```

## 10. Apply platform add-ons

```powershell
kubectl apply -f argocd/applications/platform-addons.yaml
```

Wait for:

```powershell
kubectl get applications -n argocd
kubectl get pods -n kube-system
kubectl get pods -n ingress-nginx
kubectl get pods -n external-secrets
kubectl get pods -n monitoring
kubectl get pods -n amazon-cloudwatch
```

## 11. Apply application GitOps manifest

```powershell
kubectl apply -f argocd/applications/ai-inference.yaml
```

Wait for:

```powershell
kubectl get pods -n ai-platform
kubectl get ingress -n ai-platform
kubectl get hpa -n ai-platform
```

## 12. Verify traffic

Find the ALB DNS name:

```powershell
kubectl get ingress -n ingress-nginx alb-to-nginx
```

Then test:

```powershell
curl http://<alb-dns>/health/live
curl http://<alb-dns>/health/ready
curl -X POST http://<alb-dns>/v1/inference `
  -H "Content-Type: application/json" `
  -d '{ "prompt": "Explain GitOps in one sentence.", "max_tokens": 64 }'
```

## Deployment success criteria

- Terraform apply completes.
- Nodes are Ready.
- Argo CD Applications are Synced and Healthy.
- External Secrets creates the app Kubernetes Secret.
- AI inference pods are Ready.
- ALB routes traffic to NGINX and then to the app.
- Prometheus scrapes the app ServiceMonitor.
- Grafana dashboard loads.
- CloudWatch receives application logs.
