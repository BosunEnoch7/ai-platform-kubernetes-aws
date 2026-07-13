# Screenshots checklist

Use this checklist to collect sanitized evidence after a real deployment.

Do not capture secrets, account IDs if you want privacy, tokens, private keys,
or sensitive URLs.

## Repository

- [ ] GitHub repository home showing README and architecture diagram.
- [ ] GitHub Actions CI workflow passing.
- [ ] GitHub Actions container workflow pushing image to ECR.

## Terraform / AWS

- [ ] Terraform plan summary.
- [ ] EKS cluster overview.
- [ ] EKS node group healthy.
- [ ] ECR repository with immutable image tag.
- [ ] IAM roles for IRSA.
- [ ] Secrets Manager secret container without exposing value.
- [ ] CloudWatch Logs application log group.

## Kubernetes

- [ ] `kubectl get nodes`.
- [ ] Argo CD Applications Synced and Healthy.
- [ ] `ai-platform` namespace pods Ready.
- [ ] HPA status.
- [ ] Ingress resources.
- [ ] ExternalSecret Ready.
- [ ] ServiceMonitor and PrometheusRule present.

## Traffic

- [ ] ALB DNS name.
- [ ] `/health/live` response.
- [ ] `/health/ready` response.
- [ ] `/v1/inference` successful response.

## Observability

- [ ] Prometheus target up.
- [ ] Grafana AI inference dashboard.
- [ ] Alertmanager routing page.
- [ ] CloudWatch Logs showing structured app logs.

## Documentation

- [ ] Deployment guide.
- [ ] Troubleshooting guide.
- [ ] Cost guide.
- [ ] Rollback guide.

## Portfolio polish

- [ ] Final architecture diagram.
- [ ] LinkedIn post.
- [ ] Resume bullets.
- [ ] STAR stories.
