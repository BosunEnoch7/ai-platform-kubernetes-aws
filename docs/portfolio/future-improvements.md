# Future improvements

These improvements would move the project closer to a real production platform.

## Security

- Add HTTPS with ACM certificates.
- Redirect HTTP to HTTPS at the ALB.
- Add AWS WAF for public ingress protection.
- Restrict EKS API access to trusted CIDRs or private access paths.
- Add OPA/Gatekeeper or Kyverno policies.
- Add container image vulnerability scanning gates.
- Add SBOM storage and artifact signing.

## Delivery

- Automate GitOps image tag updates with pull requests.
- Add progressive delivery with canary or blue/green rollouts.
- Add promotion flow across dev, staging, and production.
- Add branch protection and required status checks.
- Add policy-as-code checks for Terraform and Kubernetes manifests.

## Reliability

- Add load testing.
- Add chaos/failure testing.
- Add multi-AZ production NAT mode.
- Add cluster autoscaler or Karpenter.
- Add pod anti-affinity for critical workloads.
- Add SLOs and burn-rate alerts.

## Observability

- Add blackbox exporter checks for public endpoints.
- Add persistent Prometheus storage.
- Add remote write for long-term metrics.
- Add CloudWatch Logs Insights saved queries.
- Add real Alertmanager receivers with External Secrets.
- Add distributed tracing with OpenTelemetry.

## AI platform capabilities

- Replace deterministic provider with a real model/provider integration.
- Add model/provider routing.
- Add request rate limiting.
- Add token usage metrics.
- Add prompt safety checks.
- Add model latency and provider error dashboards.
- Add batch inference or async job support.

## Cost optimization

- Add scheduled shutdown for dev environments.
- Add Infracost estimates in pull requests.
- Add log sampling or filtering for noisy logs.
- Add resource rightsizing recommendations.
- Add Spot capacity for interruption-tolerant workloads.
