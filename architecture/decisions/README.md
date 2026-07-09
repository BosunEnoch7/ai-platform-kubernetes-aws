# Architecture Decision Records

ADRs document decisions that would otherwise be rediscovered or debated
without their original context.

## Status values

- **Proposed:** under discussion and not yet an implementation constraint.
- **Accepted:** approved and expected to guide implementation.
- **Superseded:** replaced by a newer ADR, which must be linked.
- **Deprecated:** retained for history but no longer recommended.

## Index

| ADR | Decision | Status |
|---|---|---|
| [0001](0001-use-amazon-eks.md) | Use Amazon EKS as the platform runtime | Accepted |
| [0002](0002-separate-infrastructure-packaging-and-delivery.md) | Separate Terraform, Helm, and Argo CD ownership | Accepted |
| [0003](0003-use-pull-based-gitops.md) | Use pull-based GitOps with Argo CD | Accepted |
| [0004](0004-use-alb-and-nginx-ingress.md) | Use an ALB-to-NGINX ingress path for the portfolio baseline | Accepted |
| [0005](0005-use-external-secrets-with-irsa.md) | Use External Secrets Operator with IRSA | Accepted |
| [0006](0006-use-s3-native-terraform-state-locking.md) | Use S3-native Terraform state locking | Accepted |
| [0007](0007-use-cost-aware-multi-az-network.md) | Use a cost-aware multi-AZ VPC | Accepted |
| [0008](0008-use-managed-node-groups-for-the-baseline.md) | Use EKS managed node groups for the baseline | Accepted |
| [0009](0009-use-immutable-images-and-secret-scoped-irsa.md) | Use immutable images and secret-scoped IRSA | Accepted |
| [0010](0010-separate-platform-addons-from-application-workloads.md) | Separate platform add-ons from application workloads | Accepted |
| [0011](0011-use-argocd-applications-for-platform-addons.md) | Use Argo CD Applications for platform add-ons | Accepted |
| [0012](0012-use-an-alb-to-nginx-bridge-ingress.md) | Use an ALB-to-NGINX bridge Ingress | Accepted |
| [0013](0013-use-argocd-for-application-delivery.md) | Use Argo CD for application delivery | Accepted |
| [0014](0014-use-github-actions-for-ci-and-image-delivery.md) | Use GitHub Actions for CI and image delivery | Accepted |
| [0015](0015-use-external-secrets-for-kubernetes-secret-projection.md) | Use External Secrets for Kubernetes secret projection | Accepted |
| [0016](0016-use-kube-prometheus-stack-for-observability.md) | Use kube-prometheus-stack for observability | Accepted |
| [0017](0017-harden-grafana-and-alertmanager-boundaries.md) | Harden Grafana and Alertmanager boundaries | Accepted |
| [0018](0018-use-cloudwatch-logs-for-container-log-shipping.md) | Use CloudWatch Logs for container log shipping | Accepted |
