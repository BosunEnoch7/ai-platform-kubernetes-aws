# ADR 0005: Use External Secrets Operator with IRSA

- **Status:** Accepted
- **Date:** 2026-07-04

## Context

AI provider credentials must not be committed to Git, embedded in images, or
stored as static AWS access keys. Native Kubernetes Secrets provide a delivery
mechanism but are not an external system of record.

## Decision

Store sensitive values in AWS Secrets Manager. Use External Secrets Operator
to reconcile approved values into namespace-scoped Kubernetes Secrets. Give
the operator narrowly scoped AWS permissions through IAM Roles for Service
Accounts (IRSA).

Application pods will consume Kubernetes Secrets and will not receive direct
permission to enumerate AWS Secrets Manager.

## Consequences

### Benefits

- AWS Secrets Manager remains the external source of truth.
- No long-lived AWS access keys are stored in the cluster or repository.
- Secret synchronization is declarative and observable.
- Application code stays independent of the AWS Secrets Manager API.

### Costs and risks

- Introduces another controller that must be secured and monitored.
- Secret material still exists in Kubernetes and therefore requires EKS
  envelope encryption, RBAC, and namespace controls.
- Rotation behavior depends on reconciliation timing and application reload
  behavior.

## Guardrails

- Scope IAM access to named secrets and required actions.
- Enable encryption of Kubernetes secrets with an AWS KMS key.
- Never expose secret values in metrics, logs, screenshots, or CI output.
- Document rotation and revocation tests before calling the design complete.
