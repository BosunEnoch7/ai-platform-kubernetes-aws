# LinkedIn post

I just completed a production-inspired AI Infrastructure portfolio project:

**ai-platform-kubernetes-aws**

The goal was not just to deploy a FastAPI app. The goal was to design the kind
of platform an AI workload would need in a real cloud-native environment:
secure deployment, GitOps, autoscaling, secrets management, observability,
logging, rollback, troubleshooting, and cost control.

What I built:

- Amazon EKS platform foundation with Terraform
- FastAPI AI inference API
- Docker image packaging and Amazon ECR
- Helm chart with probes, HPA, PDB, NetworkPolicy, and rollout strategy
- Argo CD GitOps for platform add-ons and application delivery
- AWS Load Balancer Controller plus NGINX Ingress
- IRSA for secure AWS access from Kubernetes
- AWS Secrets Manager integration through External Secrets Operator
- Prometheus, Grafana, and Alertmanager monitoring
- CloudWatch Logs with AWS for Fluent Bit
- GitHub Actions CI/CD with AWS OIDC
- Deployment guide, rollback guide, troubleshooting guide, cost guide, and
  interview documentation

Some important engineering decisions:

- Terraform owns AWS infrastructure.
- Helm packages Kubernetes workloads.
- Argo CD owns cluster reconciliation.
- GitHub Actions builds and validates artifacts.
- Secret values stay out of Git and Terraform state.
- Images use immutable Git SHA tags instead of `latest`.

This project helped me go deeper into AI Infrastructure, MLOps, DevOps,
Kubernetes, AWS, GitOps, observability, and SRE practices.

The biggest lesson:

Deploying an AI API is only a small part of the work. The real engineering is
in making it secure, observable, scalable, recoverable, and cost-aware.

Project: `ai-platform-kubernetes-aws`

#AIInfrastructure #MLOps #DevOps #Kubernetes #AWS #EKS #Terraform #ArgoCD
#GitOps #PlatformEngineering #SRE #CloudComputing
