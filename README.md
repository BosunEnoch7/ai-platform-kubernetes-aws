# AI Platform on Kubernetes and AWS

A production-inspired AI platform demonstrating how inference workloads are
deployed, secured, scaled, observed, and operated on Amazon EKS.

**Owner:** Olatubosun Enoch David

## Project intent

This repository is an infrastructure and operations portfolio project. The
inference API is intentionally small; the primary engineering work is the
platform around it:

- reproducible AWS infrastructure;
- Kubernetes application packaging;
- GitOps-based delivery;
- workload identity and external secrets;
- safe rollouts and autoscaling;
- application, Kubernetes, and AWS observability; and
- operational documentation and evidence.

## Architecture planes

The platform is separated into four concerns:

1. **Delivery plane:** GitHub Actions builds and verifies immutable images,
   Amazon ECR stores them, and Argo CD reconciles Git into EKS.
2. **Traffic plane:** an AWS load balancer forwards traffic through NGINX
   Ingress to the FastAPI service and its healthy pods.
3. **Security plane:** IAM Roles for Service Accounts (IRSA) gives workloads
   narrowly scoped AWS access, while AWS Secrets Manager owns sensitive data.
4. **Observability plane:** Prometheus, Grafana, and Alertmanager cover
   application and Kubernetes signals; CloudWatch covers AWS-native logs and
   infrastructure signals.

Detailed diagrams and threat boundaries will live in `architecture/`.

## Tool ownership

| Tool | Owns |
|---|---|
| Terraform | AWS infrastructure and foundational EKS integrations |
| Helm | The reusable Kubernetes package for the inference application |
| Argo CD | Continuous reconciliation of approved cluster state from Git |
| GitHub Actions | Testing, scanning, building, and publishing artifacts |

No tool should silently take ownership of resources managed by another tool.

## Planned repository areas

| Path | Purpose |
|---|---|
| `app/` | FastAPI service, provider abstraction, and unit tests |
| `architecture/` | Diagrams, decisions, and threat model |
| `terraform/` | AWS infrastructure modules and environment composition |
| `helm/` | Versioned inference application chart |
| `platform/` | Shared in-cluster capabilities |
| `argocd/` | GitOps bootstrap, projects, and applications |
| `monitoring/` | Dashboards, alerts, and monitoring configuration |
| `tests/` | Smoke, integration, and load tests |
| `docs/` | Deployment, operations, security, cost, and portfolio guides |
| `screenshots/` | Curated, sanitized deployment evidence |
| `scripts/` | Small repeatable validation and operational helpers |

Directories will be introduced only when their implementation phase begins.

## Delivery status

- [x] Phase 1: architecture and project foundation
- [x] Phase 2: architecture decision baseline
- [x] Phase 3: minimal inference application
- [ ] Phase 4: container build and local verification
  - [x] Secure image definition and dependency lock
  - [ ] Runtime verification (Docker engine unavailable)
- [ ] Phase 5: AWS and EKS infrastructure
  - [x] Remote-state bootstrap configuration
  - [ ] Remote-state AWS deployment and migration
  - [x] Network foundation configuration
  - [ ] Network plan and AWS deployment
  - [ ] EKS control plane and worker capacity
- [ ] Phase 6: Helm deployment package
- [ ] Phase 7: security and secrets integration
- [ ] Phase 8: ingress and traffic management
- [ ] Phase 9: observability
- [ ] Phase 10: GitOps and CI
- [ ] Phase 11: reliability, scaling, and failure testing
- [ ] Phase 12: portfolio documentation and evidence

Each phase is reviewed before the next phase begins.
