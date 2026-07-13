# ai-platform-kubernetes-aws

Production-inspired AI infrastructure platform on Amazon EKS.

**Owner:** Olatubosun Enoch David

**Project type:** AI Infrastructure, MLOps, DevOps, Platform Engineering, SRE
**Status:** Portfolio implementation in progress; core platform foundation built

## What this project demonstrates

This repository shows how an AI inference workload can be deployed, secured,
scaled, observed, and operated on Kubernetes using AWS-native and CNCF tooling.

The FastAPI inference service is intentionally small. The real engineering
value is the platform around it:

- Amazon EKS infrastructure with Terraform;
- private container images in Amazon ECR;
- secure workload identity with IRSA;
- AWS Secrets Manager integration through External Secrets Operator;
- Helm packaging for the AI inference API;
- GitOps delivery with Argo CD;
- ALB-to-NGINX ingress architecture;
- Horizontal Pod Autoscaler, probes, rolling updates, and PDBs;
- Prometheus, Grafana, Alertmanager, and CloudWatch logging;
- GitHub Actions CI/CD with AWS OIDC;
- production-style deployment, troubleshooting, rollback, and cost docs.

## Architecture

```mermaid
flowchart TD
  client[Client] --> alb[AWS Application Load Balancer]
  alb --> nginx[NGINX Ingress Controller]
  nginx --> svc[Kubernetes Service]
  svc --> pods[FastAPI AI Inference Pods]
  pods --> provider[AI Provider Layer]

  pods --> metrics[/metrics]
  metrics --> prometheus[Prometheus]
  prometheus --> grafana[Grafana]
  prometheus --> alertmanager[Alertmanager]

  pods --> stdout[JSON stdout logs]
  stdout --> fluentbit[AWS for Fluent Bit]
  fluentbit --> cloudwatch[CloudWatch Logs]

  secrets[AWS Secrets Manager] --> eso[External Secrets Operator]
  eso --> k8ssecret[Kubernetes Secret]
  k8ssecret --> pods
```

More diagrams:

- [System architecture](architecture/diagrams/system-architecture.md)
- [Delivery flow](architecture/diagrams/delivery-flow.md)
- [Observability flow](architecture/diagrams/observability-flow.md)

## Tool ownership model

| Tool | Owns |
|---|---|
| Terraform | AWS infrastructure, EKS, IAM, ECR, Secrets Manager, CloudWatch Logs |
| Helm | Reusable Kubernetes package for the AI inference application |
| Argo CD | GitOps reconciliation of platform add-ons and app workloads |
| GitHub Actions | Tests, validation, image build, and ECR push |
| Prometheus/Grafana/Alertmanager | Metrics, dashboards, and alerting |
| CloudWatch Logs | Centralized AWS log storage |

No tool should silently take ownership of resources managed by another tool.

## Repository map

| Path | Purpose |
|---|---|
| `app/` | FastAPI inference API, provider abstraction, metrics, tests |
| `terraform/` | AWS infrastructure modules and dev environment |
| `helm/ai-inference/` | Production-style Helm chart for the app |
| `argocd/` | Argo CD projects and Applications |
| `k8s/` | Platform manifests such as ALB bridge and Grafana dashboard |
| `architecture/` | ADRs and architecture diagrams |
| `docs/` | Deployment, operations, security, observability, and cost guides |
| `screenshots/` | Sanitized running evidence after live deployment |
| `.github/workflows/` | CI and container build pipelines |

## Major platform features

### Infrastructure

- Multi-AZ VPC foundation.
- Public/private subnet separation.
- Cost-aware NAT Gateway strategy.
- Amazon EKS managed node group baseline.
- EKS OIDC provider for IRSA.
- S3-native Terraform state locking.

### Application delivery

- FastAPI inference API.
- Docker image with non-root runtime user.
- Immutable image tags.
- Amazon ECR private repository.
- Helm chart with schema validation.
- Argo CD app deployment.
- GitHub Actions CI and image build workflow.

### Traffic management

- AWS Load Balancer Controller.
- NGINX Ingress Controller.
- ALB-to-NGINX bridge.
- App-level Ingress using `ingressClassName: nginx`.
- Readiness/liveness probes.
- Rolling updates with `maxUnavailable: 0`.

### Security

- IRSA for app workload, AWS Load Balancer Controller, External Secrets, and Fluent Bit.
- AWS Secrets Manager as the secret source of truth.
- External Secrets Operator for Kubernetes Secret projection.
- Read-only container filesystem.
- Dropped Linux capabilities.
- NetworkPolicy baseline.
- No secret values committed to Git or Terraform state.

### Reliability and scaling

- HPA with CPU target.
- PodDisruptionBudget.
- Soft topology spread constraints.
- Resource requests and limits.
- Explicit rollback guide.
- Operational runbooks.

### Observability

- Prometheus metrics from `/metrics`.
- ServiceMonitor and PrometheusRule.
- Grafana dashboard ConfigMap.
- Alertmanager routing model.
- CloudWatch Logs via AWS for Fluent Bit.
- Structured JSON app logs.

## Deployment documentation

Start here:

- [Production deployment guide](docs/deployment/production-deployment-guide.md)
- [Verification checklist](docs/deployment/verification-checklist.md)
- [GitOps application deployment](docs/deployment/gitops-application.md)
- [Local container deployment](docs/deployment/local-container.md)

Operations:

- [Runbooks](docs/operations/runbooks.md)
- [Troubleshooting guide](docs/operations/troubleshooting.md)
- [Rollback guide](docs/operations/rollback.md)

Security and observability:

- [Secrets management](docs/security/secrets-management.md)
- [Monitoring foundation](docs/observability/monitoring.md)
- [CloudWatch logging](docs/observability/cloudwatch-logging.md)
- [Grafana hardening](docs/observability/grafana-hardening.md)
- [Alertmanager routing](docs/observability/alertmanager-routing.md)

Cost:

- [Cost optimization](docs/cost/cost-optimization.md)
- [Teardown guide](docs/cost/teardown.md)

## Running screenshots and evidence

Live screenshots are intentionally separated from source code and should be
captured only after a real deployment. Do not include secrets, tokens, private
keys, or sensitive account details.

Use:

- [Screenshots folder guide](screenshots/README.md)
- [Screenshots checklist](docs/portfolio/screenshots-checklist.md)

Recommended evidence to capture:

| Area | Screenshot evidence |
|---|---|
| GitHub | README, passing CI workflow, container workflow |
| AWS | EKS cluster, node group, ECR image tag, IRSA roles, CloudWatch log group |
| Kubernetes | Argo CD apps, pods Ready, HPA, Ingress, ExternalSecret |
| Traffic | `/health/live`, `/health/ready`, `/v1/inference` responses |
| Observability | Prometheus target, Grafana dashboard, Alertmanager routing, CloudWatch logs |

## Important deployment placeholders

Before applying to a real cluster, replace:

- `REPLACE_WITH_GITHUB_USERNAME`
- placeholder AWS account IDs such as `000000000000`
- placeholder IRSA role ARNs
- `vpc-replace-with-terraform-output`
- `replace-with-commit-sha`
- `REPLACE_WITH_PINNED_KUBE_PROMETHEUS_STACK_VERSION`

These values should come from Terraform outputs, CI output, and verified chart
indexes.

## Validation commands

```powershell
python -m ruff check .
python -m pytest
terraform "-chdir=terraform" fmt -recursive -check
terraform "-chdir=terraform/environments/dev" validate
helm lint ./helm/ai-inference --values ./helm/ai-inference/values-dev.yaml
```

## What recruiters should notice

This project is not just “an app on Kubernetes.” It demonstrates platform
engineering judgement:

- clear ownership boundaries between Terraform, Helm, Argo CD, and CI/CD;
- secure AWS access through IRSA instead of static credentials;
- GitOps-driven deployment instead of manual cluster mutation;
- production-style observability and logging;
- cost-aware architecture decisions;
- operational documentation for deployment, rollback, and troubleshooting.

## Current limitations

- No live AWS deployment evidence has been captured yet.
- Docker runtime verification depends on a local Docker engine.
- `kube-prometheus-stack` chart version must be pinned before real cluster apply.
- Production TLS, WAF, and Alertmanager receiver integrations are documented but
  not yet wired with real secrets.

These are intentional and documented so the project remains honest.
