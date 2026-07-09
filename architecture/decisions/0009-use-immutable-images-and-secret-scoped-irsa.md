# ADR 0009: Use immutable images and secret-scoped IRSA

## Status

Accepted

## Context

The inference workload needs a trustworthy artifact and an AI provider
credential. Shared node credentials, broad IAM, mutable tags, and secrets in
Terraform state weaken traceability and increase blast radius.

## Decision

Use a private, KMS-encrypted ECR repository with immutable tags, scan-on-push,
and lifecycle cleanup. CI will publish unique commit-SHA tags.

Terraform creates only the Secrets Manager container, not its value. Bind one
IAM role to the exact Kubernetes namespace and service account. It can read
only this secret and decrypt it only through Secrets Manager.

## Consequences

- Deployments reference stable, auditable artifacts.
- A compromised workload cannot access unrelated secrets.
- Lifecycle cleanup controls registry storage cost.
- Every build needs a unique image tag.
- Secret population is an explicit operation outside Terraform.
