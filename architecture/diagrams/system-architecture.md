# System architecture

```mermaid
flowchart TD
  client["Client"] --> alb["AWS Application Load Balancer"]
  alb --> nginx["NGINX Ingress Controller"]
  nginx --> appIngress["App Ingress"]
  appIngress --> service["Kubernetes Service"]
  service --> pods["FastAPI AI Inference Pods"]
  pods --> provider["AI Provider Layer"]

  secretsManager["AWS Secrets Manager"] --> externalSecrets["External Secrets Operator"]
  externalSecrets --> k8sSecret["Kubernetes Secret"]
  k8sSecret --> pods

  pods --> metrics["/metrics endpoint"]
  metrics --> prometheus["Prometheus"]
  prometheus --> grafana["Grafana"]
  prometheus --> alertmanager["Alertmanager"]

  pods --> logs["stdout JSON logs"]
  logs --> fluentBit["AWS for Fluent Bit"]
  fluentBit --> cloudWatch["CloudWatch Logs"]
```

## Boundary notes

- The ALB is AWS-facing.
- NGINX owns in-cluster HTTP routing.
- The application Helm chart owns the app Deployment, Service, Ingress, HPA,
  PDB, ServiceMonitor, PrometheusRule, SecretStore, and ExternalSecret.
- Terraform owns AWS infrastructure and IAM.
- Argo CD reconciles Kubernetes desired state from Git.
