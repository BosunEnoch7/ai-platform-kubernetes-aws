# ADR 0002: Separate infrastructure, packaging, and delivery ownership

- **Status:** Accepted
- **Date:** 2026-07-04

## Context

Terraform, Helm, and Argo CD can all create resources. Without strict
boundaries, two tools may compete for the same object, causing drift,
unpredictable reconciliation, and unsafe deletion behavior.

## Decision

- **Terraform** owns AWS infrastructure, IAM, ECR, EKS, and foundational AWS
  integrations.
- **Helm** defines the reusable Kubernetes package for the inference
  application.
- **Argo CD** owns continuous reconciliation of approved Kubernetes state from
  Git.
- **GitHub Actions** tests, scans, builds, and publishes artifacts; it does not
  directly deploy application resources to the cluster.

Terraform may bootstrap Argo CD only to establish the GitOps control loop.
After bootstrap, Argo CD owns its declared applications.

## Consequences

### Benefits

- One authoritative owner exists for each resource.
- Drift and rollback behavior are easier to understand.
- CI does not require broad, persistent cluster deployment credentials.

### Costs and risks

- Bootstrap ordering must be documented.
- Changes spanning AWS and Kubernetes may require coordinated pull requests.
- Engineers must resist convenient one-off changes through `kubectl`.

## Guardrails

- Every managed resource must have a documented owner.
- Emergency manual changes must be recorded and reconciled back into Git.
- CI will render and validate Helm output without becoming the deployer.
