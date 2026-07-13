# Lessons learned

## 1. The application is not the platform

The FastAPI service is only one part of the system. A production-inspired AI
platform also needs identity, secrets, traffic management, observability,
logging, CI/CD, rollout safety, and cost controls.

## 2. Ownership boundaries matter

Terraform, Helm, Argo CD, and GitHub Actions can easily overlap. The project is
stronger because each tool has a clear responsibility:

- Terraform owns AWS infrastructure.
- Helm packages Kubernetes resources.
- Argo CD reconciles cluster state.
- GitHub Actions validates and publishes artifacts.

## 3. Secret values should not enter Terraform state

Terraform can create the secret container and IAM policy, but storing live
secret values in Terraform state is risky. External Secrets Operator gives a
cleaner runtime path from AWS Secrets Manager to Kubernetes.

## 4. GitOps is an operating model, not just a tool

Using Argo CD means Git should describe desired cluster state. CI should not
quietly mutate the cluster behind Argo CD's back.

## 5. Observability has to be designed

Installing Prometheus is not enough. The app needs meaningful metrics, bounded
labels, ServiceMonitor discovery, alert rules, dashboards, and logs that help
debug real incidents.

## 6. Production trade-offs should be explicit

ALB plus NGINX demonstrates cloud and in-cluster routing, but it adds cost and
latency. A strong engineer can explain when that trade-off is worth it and when
to simplify.

## 7. Cost is part of architecture

NAT Gateway mode, node sizes, log retention, Prometheus retention, ECR cleanup,
and teardown discipline all affect cost. Platform engineering includes cost
awareness.

## 8. Documentation is engineering evidence

Deployment guides, runbooks, troubleshooting guides, and rollback steps show
that the system was designed to be operated, not just created.
