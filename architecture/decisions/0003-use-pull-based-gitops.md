# ADR 0003: Use pull-based GitOps with Argo CD

- **Status:** Accepted
- **Date:** 2026-07-04

## Context

A push-based pipeline can deploy directly from GitHub Actions, but it requires
CI to hold cluster access and makes deployment state dependent on a transient
workflow run.

The platform needs drift detection, a visible desired state, and an auditable
rollback path.

## Decision

Use Argo CD to pull approved desired state from Git and reconcile it into EKS.
GitHub Actions will publish immutable container images and validate deployment
configuration. Promotion will occur through a reviewed Git change.

## Consequences

### Benefits

- Git history becomes the deployment audit trail.
- Argo CD continuously detects and reports drift.
- Rollback is expressed through a reviewed change to desired state.
- CI needs fewer cluster privileges.

### Costs and risks

- Argo CD becomes a critical platform component that must be secured,
  monitored, backed up, and upgraded.
- Careless automatic synchronization can rapidly apply a bad declaration.
- Image promotion requires an explicit, well-documented mechanism.

## Guardrails

- Use immutable image tags or digests, never `latest`.
- Begin with manual approval for production synchronization.
- Restrict Argo CD projects by repository, namespace, and destination.
