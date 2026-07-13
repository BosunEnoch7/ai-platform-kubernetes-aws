# Interview guide

Use this guide to explain the project clearly in interviews.

## 30-second summary

I built a production-inspired AI inference platform on Amazon EKS. The project
uses Terraform for AWS infrastructure, Helm for application packaging, Argo CD
for GitOps delivery, GitHub Actions for CI/CD, IRSA for secure AWS access,
External Secrets Operator for Secrets Manager integration, and
Prometheus/Grafana/Alertmanager plus CloudWatch for observability.

The FastAPI inference service is intentionally small. The main value is the
platform around it: secure deployment, traffic management, autoscaling,
monitoring, logging, rollback, troubleshooting, and cost-aware operations.

## 2-minute architecture explanation

Client traffic enters through an AWS Application Load Balancer created by AWS
Load Balancer Controller. The ALB forwards traffic to the NGINX Ingress
Controller, which routes requests to the FastAPI AI inference Service and pods.

The workload is packaged with Helm and deployed through Argo CD. CI builds and
pushes immutable Docker images to ECR, but Argo CD owns Kubernetes deployment so
Git remains the source of truth.

Secrets live in AWS Secrets Manager. Terraform creates the secret container and
IAM roles, but not the secret value. External Secrets Operator syncs approved
secret values into Kubernetes using IRSA.

Prometheus scrapes `/metrics` using a ServiceMonitor, Grafana visualizes app
metrics, Alertmanager handles alert routing, and AWS for Fluent Bit ships JSON
container logs to CloudWatch Logs.

## Why Amazon EKS?

EKS lets me demonstrate managed Kubernetes operations while still dealing with
real platform engineering concerns:

- AWS IAM integration;
- load balancer integration;
- VPC and subnet design;
- managed node groups;
- CloudWatch logging;
- production-style security boundaries.

The trade-off is complexity and cost. For a simple API, ECS or App Runner would
be simpler. I chose EKS because the portfolio goal is to demonstrate Kubernetes
platform engineering.

## Why Terraform, Helm, and Argo CD together?

Each tool owns a different layer:

- Terraform owns AWS infrastructure and IAM.
- Helm packages Kubernetes application resources.
- Argo CD reconciles desired cluster state from Git.

I avoided letting Terraform install application Helm releases because that can
create ownership conflicts with Argo CD.

## Why IRSA?

IRSA gives Kubernetes service accounts scoped AWS permissions without static AWS
keys. The app, AWS Load Balancer Controller, External Secrets Operator, and AWS
for Fluent Bit each get only the permissions they need.

## Why External Secrets Operator?

It keeps AWS Secrets Manager as the source of truth while allowing Kubernetes
workloads to consume native Kubernetes Secrets. It also prevents secret values
from being stored in Terraform state or Git.

## Why ALB plus NGINX?

Using both is more complex than using only one. I chose it intentionally to show
two layers:

- ALB handles AWS-facing entry.
- NGINX handles in-cluster HTTP routing.

For a low-latency or cost-sensitive production system, direct ALB-to-service
routing might be better. The project documents that trade-off instead of hiding
it.

## Why Prometheus and CloudWatch?

Prometheus is strong for Kubernetes and application metrics. CloudWatch is the
native AWS place for centralized logs and AWS infrastructure signals.

Metrics answer “is something wrong?” Logs help answer “what happened?”

## Strong talking points

- I separated infrastructure, packaging, and delivery ownership.
- I used IRSA instead of static cloud credentials.
- I avoided storing secret values in Terraform state.
- I used immutable image tags for traceable deployments.
- I documented rollback, troubleshooting, cost, and teardown.
- I made production trade-offs explicit instead of pretending everything is
  universally optimal.

## Questions you may be asked

### How would you make this production-ready?

- Pin all remaining chart versions.
- Add HTTPS with ACM and HTTP-to-HTTPS redirect.
- Add AWS WAF for public ingress.
- Configure real Alertmanager receivers.
- Add persistent storage and remote write for Prometheus.
- Add SLOs and burn-rate alerts.
- Add load testing and failure testing.
- Restrict EKS API access.
- Add progressive delivery with canary or blue/green.

### What would you simplify?

For a single API, I might remove NGINX and route ALB directly to the app
Service. That would reduce cost, latency, and troubleshooting complexity.

### What is the biggest risk?

The biggest operational risk is complexity across many controllers: AWS Load
Balancer Controller, NGINX, Argo CD, External Secrets, Prometheus Operator, and
Fluent Bit. The mitigation is clear ownership, documentation, pinned versions,
and strong troubleshooting runbooks.

### How does this differ from a basic AI inference app?

A basic AI inference app focuses on serving an endpoint. This project focuses on
the platform needed to operate that endpoint safely: infrastructure, GitOps,
secrets, ingress, autoscaling, observability, logging, rollback, and cost
controls.
