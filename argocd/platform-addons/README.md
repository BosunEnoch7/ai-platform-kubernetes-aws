# Platform add-ons Applications

These Argo CD `Application` manifests install shared platform controllers with
Helm.

## Pinned chart versions

| Add-on | Chart repository | Chart version | App version |
|---|---|---:|---:|
| AWS Load Balancer Controller | `https://aws.github.io/eks-charts` | `3.4.0` | `v3.4.0` |
| ingress-nginx | `https://kubernetes.github.io/ingress-nginx` | `4.15.1` | `1.15.1` |
| metrics-server | `https://kubernetes-sigs.github.io/metrics-server` | `3.13.1` | `0.8.1` |
| External Secrets Operator | `https://charts.external-secrets.io` | `2.7.0` | `v2.7.0` |
| AWS for Fluent Bit | `https://aws.github.io/eks-charts` | `0.2.0` | `3.2.1` |
| kube-prometheus-stack | `https://prometheus-community.github.io/helm-charts` | replace before apply | Prometheus, Grafana, Alertmanager |
| Grafana dashboards | repository path `k8s/monitoring/grafana-dashboards` | Git `main` | Dashboard ConfigMaps |
| ALB-to-NGINX bridge | repository path `k8s/platform/alb-to-nginx` | Git `main` | Kubernetes Ingress |

The versions above were taken from the official Helm chart indexes. Pinning
versions keeps demos repeatable and makes upgrades explicit.

The ALB-to-NGINX bridge tracks the repository branch because it is a local
Kubernetes manifest, not a third-party Helm chart.

## Required replacements before cluster apply

In `aws-load-balancer-controller.yaml`, replace:

- `vpc-replace-with-terraform-output` with Terraform output `vpc_id`;
- the placeholder role ARN with Terraform output
  `aws_load_balancer_controller_role_arn`;
- `clusterName` and `region` if you change the default dev environment.

In `external-secrets.yaml`, replace the placeholder role ARN with Terraform
output `external_secrets_role_arn`.

In `aws-for-fluent-bit.yaml`, replace the placeholder role ARN with Terraform
output `aws_for_fluent_bit_role_arn` and confirm `logGroupName` matches
Terraform output `application_log_group_name`.

In `kube-prometheus-stack.yaml`, replace
`REPLACE_WITH_PINNED_KUBE_PROMETHEUS_STACK_VERSION` with a current chart
version from the official Prometheus Community Helm index before applying.

## Why NGINX is ClusterIP

The NGINX controller is configured with `service.type: ClusterIP` so it remains
internal to the cluster. A later phase will add the ALB-to-NGINX bridge owned by
AWS Load Balancer Controller.

That produces the requested portfolio path:

```text
AWS Application Load Balancer
→ NGINX Ingress Controller
→ app Ingress
→ app Service
→ FastAPI pods
```
