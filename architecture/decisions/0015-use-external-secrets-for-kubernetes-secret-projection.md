# ADR 0015: Use External Secrets for Kubernetes secret projection

## Status

Accepted

## Context

The AI inference workload needs a production-inspired path for consuming
provider credentials. The project already creates an encrypted AWS Secrets
Manager secret container, but the secret value must not be stored in Terraform
state or committed to Git.

## Decision

Use External Secrets Operator to project selected AWS Secrets Manager values
into a namespaced Kubernetes Secret.

Terraform creates the External Secrets Operator IRSA role and scopes it to the
approved AWS secret and KMS key. Argo CD installs the operator. The application
Helm chart creates the app-specific `SecretStore` and `ExternalSecret`.

## Rationale

This keeps clear ownership boundaries:

- AWS secret container and IAM are managed by Terraform;
- the shared operator is managed by the platform GitOps layer;
- app-specific secret mapping is managed by the app Helm chart;
- actual secret values are managed operationally outside Git and Terraform.

## Trade-offs

The app receives a Kubernetes Secret, so the value exists inside the cluster.
That is normal for many Kubernetes workloads, but access to Secrets must be
controlled with RBAC and audit logging.

Environment variable consumption is simple, but apps may need a restart to pick
up rotated values. File mounts or reload controllers can improve rotation
behavior later.

## Consequences

- No secret values are committed to Git.
- Terraform state does not contain live secret values.
- Secret access is scoped with IRSA.
- The deployment path remains Kubernetes-native.
