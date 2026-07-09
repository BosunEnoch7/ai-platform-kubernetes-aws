# ADR 0013: Use Argo CD for application delivery

## Status

Accepted

## Context

The AI inference API is packaged as a Helm chart. The platform needs a
repeatable way to deploy and reconcile that chart into Amazon EKS.

Manual `helm install` commands are useful during learning, but they do not
provide continuous drift correction or a strong audit trail.

## Decision

Deploy the AI inference application using an Argo CD `Application` that points
at the repository-local Helm chart.

Use a dedicated Argo CD `AppProject` named `ai-platform` and restrict it to the
`ai-platform` namespace.

## Rationale

This keeps platform add-ons and application workloads separate. The app project
does not need permission to manage cluster-wide resources. It only needs the
namespaced resources produced by the application Helm chart.

The application uses immutable image tags so Git describes the exact desired
runtime artifact.

## Trade-offs

Automated sync with pruning is convenient for a development portfolio
environment, but it can be risky in production if a bad commit deletes
resources. Sensitive environments may require manual sync, approvals, or
progressive delivery.

## Consequences

- Application deployment is declarative and auditable.
- Drift can be detected and repaired by Argo CD.
- CI/CD can update only image tags instead of applying Kubernetes manifests
  directly.
