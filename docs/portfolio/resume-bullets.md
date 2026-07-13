# Resume bullet points

Use these as starting points. Pick the strongest 3-5 depending on the role.

## AI Infrastructure / MLOps

- Built a production-inspired AI inference platform on Amazon EKS using
  Terraform, Helm, Argo CD, GitHub Actions, Amazon ECR, and FastAPI.
- Designed a GitOps-based deployment model for AI workloads, separating CI image
  delivery from Argo CD cluster reconciliation.
- Packaged a FastAPI inference service with Helm, including HPA, probes,
  rolling updates, PodDisruptionBudget, NetworkPolicy, ServiceMonitor, and
  PrometheusRule resources.
- Implemented secure secret delivery from AWS Secrets Manager to Kubernetes
  using External Secrets Operator and IAM Roles for Service Accounts.

## DevOps / Platform Engineering

- Provisioned AWS platform foundations with Terraform, including VPC, EKS, ECR,
  IAM, Secrets Manager, CloudWatch Logs, and controller-specific IRSA roles.
- Built GitHub Actions pipelines for Python tests, linting, Terraform
  validation, Helm rendering, YAML validation, Docker image build, and ECR push.
- Designed clear ownership boundaries between Terraform, Helm, Argo CD, and
  GitHub Actions to reduce drift and deployment conflicts.
- Implemented ALB-to-NGINX ingress architecture using AWS Load Balancer
  Controller and NGINX Ingress Controller.

## Kubernetes / SRE

- Added production-style Kubernetes reliability controls including readiness and
  liveness probes, HPA, PDB, resource requests/limits, and topology spread
  constraints.
- Integrated Prometheus, Grafana, and Alertmanager using ServiceMonitor,
  PrometheusRule, dashboard ConfigMaps, and documented alert routing.
- Centralized structured application logs in CloudWatch Logs using AWS for
  Fluent Bit with IRSA and explicit log retention.
- Authored operational runbooks, rollback procedures, troubleshooting guide,
  verification checklist, and cost optimization guide for an EKS AI platform.

## Strong compact version

- Built an EKS-based AI inference platform with Terraform, Helm, Argo CD,
  GitHub Actions, ECR, IRSA, External Secrets, Prometheus/Grafana/Alertmanager,
  and CloudWatch, demonstrating secure GitOps delivery and production-style
  operations.
