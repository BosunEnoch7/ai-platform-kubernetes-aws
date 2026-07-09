# Verification checklist

Use this checklist after deployment or major changes.

## Terraform

```powershell
terraform -chdir=terraform/environments/dev output
```

Expected:

- EKS cluster outputs exist.
- ECR repository output exists.
- IRSA role outputs exist.
- CloudWatch log group output exists.

## Cluster health

```powershell
kubectl get nodes
kubectl get pods -A
```

Expected:

- all nodes are `Ready`;
- system pods are not crash-looping;
- application pods are `Running` and `Ready`.

## Argo CD

```powershell
kubectl get applications -n argocd
```

Expected:

- platform add-ons are `Synced`;
- AI inference app is `Synced`;
- no application remains in repeated `Progressing` or `Degraded` state.

## Secrets

```powershell
kubectl get externalsecret -n ai-platform
kubectl get secret -n ai-platform ai-provider
```

Expected:

- ExternalSecret reports Ready;
- Kubernetes Secret exists;
- secret value is not printed to the terminal.

## Ingress path

```powershell
kubectl get ingress -n ingress-nginx alb-to-nginx
kubectl get ingress -n ai-platform
```

Expected:

- ALB bridge has an address;
- app Ingress uses `ingressClassName: nginx`.

## Application health

```powershell
curl http://<alb-dns>/health/live
curl http://<alb-dns>/health/ready
```

Expected:

- liveness returns `alive`;
- readiness returns `ready`.

## Inference

```powershell
curl -X POST http://<alb-dns>/v1/inference `
  -H "Content-Type: application/json" `
  -d '{ "prompt": "Hello platform", "max_tokens": 32 }'
```

Expected:

- HTTP 200;
- response includes `request_id`;
- response includes provider output.

## Autoscaling

```powershell
kubectl get hpa -n ai-platform
kubectl top pods -n ai-platform
```

Expected:

- HPA can read CPU metrics;
- Metrics Server is working.

## Monitoring

```powershell
kubectl get servicemonitor -n ai-platform
kubectl get prometheusrule -n ai-platform
```

Expected:

- ServiceMonitor exists;
- PrometheusRule exists;
- Prometheus target for the app is up.

## Logging

```powershell
aws logs describe-log-groups `
  --log-group-name-prefix /aws/eks/ai-platform-kubernetes-aws-dev/application
```

Expected:

- application log group exists;
- new log streams appear after app traffic.
