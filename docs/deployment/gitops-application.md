# GitOps application deployment

This guide explains how the AI inference application is represented in Argo CD.

## Deployment flow

```text
Git commit
→ Argo CD Application
→ Helm chart render
→ Kubernetes namespace ai-platform
→ Deployment, Service, HPA, PDB, Ingress, NetworkPolicy
```

## Application manifest

The application manifest lives at:

```text
argocd/applications/ai-inference.yaml
```

It points Argo CD at the local Helm chart:

```text
helm/ai-inference
```

## Values strategy

The chart has safe defaults in `values.yaml` and development overrides in
`values-dev.yaml`.

Argo CD also sets deployment-specific parameters:

- image repository;
- immutable image tag;
- workload IRSA role annotation.

These values are intentionally placeholders until Terraform and CI/CD produce
the real values.

## Sync policy

The application uses automated sync with:

- `prune: true` to remove resources deleted from Git;
- `selfHeal: true` to correct live drift;
- `CreateNamespace=true` to create `ai-platform`;
- retry backoff for transient reconciliation failures.

## Production caution

Automated pruning is powerful. In production, teams often start with manual sync
or require approvals for sensitive environments. For this portfolio dev
environment, automated sync demonstrates the desired GitOps operating model.
