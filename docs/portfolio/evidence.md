# Portfolio evidence and validation notes

This project is meant to show production-style AI platform engineering, not
just application code. Evidence is grouped into three layers so reviewers can
quickly understand what has been built, how it is validated, and what should be
captured during a live AWS demo.

## 1. Repository evidence

| Evidence | Where to review |
|---|---|
| FastAPI inference workload | [`app/`](../../app/) |
| Docker packaging | [`app/Dockerfile`](../../app/Dockerfile) |
| Helm workload chart | [`helm/ai-inference/`](../../helm/ai-inference/) |
| Terraform AWS platform | [`terraform/`](../../terraform/) |
| Argo CD GitOps applications | [`argocd/`](../../argocd/) |
| Kubernetes platform manifests | [`k8s/`](../../k8s/) |
| GitHub Actions OIDC image publisher role | [`terraform/modules/workload_foundation/github_actions_oidc.tf`](../../terraform/modules/workload_foundation/github_actions_oidc.tf) |
| Architecture diagrams | [`architecture/diagrams/`](../../architecture/diagrams/) |
| Architecture decisions | [`architecture/decisions/`](../../architecture/decisions/) |
| Operations docs | [`docs/operations/`](../operations/) |
| Security docs | [`docs/security/`](../security/) |
| Observability docs | [`docs/observability/`](../observability/) |
| Cost and teardown docs | [`docs/cost/`](../cost/) |

## 2. Validation evidence to run locally

These commands validate the repository without keeping AWS infrastructure
running:

```powershell
python -m ruff check .
python -m pytest
terraform "-chdir=terraform" fmt -recursive -check
terraform "-chdir=terraform/environments/dev" validate
helm lint ./helm/ai-inference --values ./helm/ai-inference/values-dev.yaml
```

Latest local validation recorded on July 15, 2026:

| Check | Result |
|---|---|
| `python -m ruff check .` | Passed |
| `python -m pytest` | Passed: 7 tests |
| `terraform -chdir=terraform fmt -recursive -check` | Passed |
| `terraform -chdir=terraform/environments/dev init -backend=false` | Passed |
| `terraform -chdir=terraform/environments/dev validate` | Passed |
| `helm lint ./helm/ai-inference --values ./helm/ai-inference/values-dev.yaml` | Passed |

Why this matters:

- Python checks prove the API code is testable and maintainable.
- Terraform validation proves the infrastructure graph is syntactically sound.
- Helm lint proves the workload package renders cleanly with environment values.
- GitOps manifests show how the platform would reconcile from Git once the
  cluster exists.

## 3. Live AWS evidence to capture during a controlled demo

For cost control, do not leave the environment running just to have screenshots.
Instead, create a short demo window:

1. Create the Terraform backend.
2. Apply the dev EKS environment.
3. Build and push the image to ECR.
4. Apply Argo CD platform and application manifests.
5. Capture sanitized screenshots.
6. Tear the environment down immediately after review.

Recommended screenshots:

| Area | Screenshot |
|---|---|
| AWS | EKS cluster active, node group ready, ECR image tag, IAM roles for IRSA |
| Kubernetes | Argo CD apps healthy, pods ready, HPA present, ingress address present |
| Application | `/health/live`, `/health/ready`, and `/v1/inference` responses |
| Observability | Prometheus target up, Grafana dashboard, CloudWatch structured logs |
| Operations | Cost Explorer/Budget view after teardown, if safe to share |

See the full checklist in
[`docs/portfolio/screenshots-checklist.md`](screenshots-checklist.md).

## Live evidence status

No public screenshots are currently committed. That is intentional: weak or
generic images make the portfolio look less credible. The next evidence pass
should capture real AWS Console, GitHub Actions, Kubernetes, Argo CD,
Prometheus, Grafana, Alertmanager, CloudWatch, and application screenshots
during a short controlled deployment window.

The July 16, 2026 validation work proved the Terraform-managed AWS foundation
could reach a clean reconciled state before teardown. The final public
repository should still use real visual evidence captured directly from the
running platform before a recruiter-facing release.

## Cost-control evidence

A production-minded portfolio should show teardown discipline. After each demo,
verify the expensive resources are gone:

```powershell
aws eks list-clusters --region eu-west-1
aws ec2 describe-nat-gateways --region eu-west-1 --filter Name=state,Values=available,pending,deleting
aws ec2 describe-addresses --region eu-west-1
aws elbv2 describe-load-balancers --region eu-west-1
```

Expected result after teardown:

- no active EKS demo cluster;
- no active NAT Gateway;
- no unused Elastic IP;
- no leftover public load balancer;
- only intentionally retained low-cost artifacts, if any.

## Reviewer takeaway

The strongest signal in this project is not that it can run one FastAPI
container. The signal is that the platform has clear ownership boundaries:

- Terraform owns AWS infrastructure;
- GitHub Actions owns test/build/push;
- Helm owns reusable Kubernetes packaging;
- Argo CD owns cluster reconciliation;
- Prometheus, Grafana, Alertmanager, and CloudWatch own operational visibility;
- teardown docs own cost safety.

That is the engineering maturity recruiters and platform teams should notice.
