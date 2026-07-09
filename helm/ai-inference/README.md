# AI inference Helm chart

This chart owns the Kubernetes workload layer only. Terraform owns AWS
infrastructure, while Argo CD will own release reconciliation in a later phase.

## Why these defaults

- Two minimum replicas and a PodDisruptionBudget preserve one serving replica
  during voluntary disruption.
- A zero-unavailable rolling update avoids intentionally dropping capacity.
- CPU requests give the HPA a meaningful utilization denominator.
- Readiness protects traffic; liveness is reserved for process recovery.
- A read-only filesystem, non-root UID, dropped capabilities, and runtime
  seccomp reduce container privileges.
- A small in-memory `/tmp` volume gives libraries a safe writable scratch path
  without making the container root filesystem writable.
- Zone spreading is soft (`ScheduleAnyway`) so a small development cluster can
  still schedule the workload.
- NetworkPolicy allows ingress only from the ingress and monitoring namespaces.
- Ingress uses `ingressClassName: nginx` because the app chart should describe
  HTTP routing, while the platform layer owns the AWS load balancer.
- ExternalSecret projects approved AWS Secrets Manager keys into a namespaced
  Kubernetes Secret without committing secret values to Git.

The chart assumes a CNI that enforces Kubernetes NetworkPolicy. Amazon VPC CNI
requires its network-policy capability to be enabled; that platform control is
handled separately.

## Render locally

The chart includes `values.schema.json`, so `helm lint` validates required
image settings, probe paths, service ports, autoscaling bounds, rollout values,
and supported application config before a release is rendered.

```powershell
helm lint ./helm/ai-inference --values ./helm/ai-inference/values-dev.yaml
helm template ai-inference ./helm/ai-inference `
  --namespace ai-platform `
  --values ./helm/ai-inference/values-dev.yaml
```

Never commit real account IDs, role ARNs, secret values, or credentials in a
values file. Argo CD will receive deployable non-secret values later.

## Secrets

The chart can create:

- a namespaced `SecretStore` that points to AWS Secrets Manager;
- an `ExternalSecret` that syncs selected remote secret properties into a
  Kubernetes Secret;
- a Deployment `secretRef` that exposes those values to the app process.

The default remote secret name matches the Terraform-created secret container:

```text
ai-platform-kubernetes-aws-dev/ai-provider
```

Only the secret name and property mapping live in Git. The actual secret value
must be inserted into AWS Secrets Manager outside Terraform.
