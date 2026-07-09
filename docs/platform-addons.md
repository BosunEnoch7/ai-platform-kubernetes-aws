# Platform add-ons foundation

Platform add-ons provide shared cluster capabilities. They sit between AWS
infrastructure and application workloads.

## Add-on ownership model

| Layer | Owns | Tool |
|---|---|---|
| AWS prerequisites | IAM roles, policies, VPC, EKS, ECR, Secrets Manager | Terraform |
| Cluster add-ons | AWS Load Balancer Controller, NGINX Ingress, Metrics Server | Argo CD + Helm |
| Application workload | FastAPI Deployment, Service, Ingress, HPA, PDB | Argo CD + app Helm chart |

## AWS Load Balancer Controller

The AWS Load Balancer Controller watches Kubernetes Ingress and Service
resources and reconciles AWS load balancers.

In this project, it is a platform controller, not an application dependency.
Terraform creates its IRSA role because that role is an AWS identity. Argo CD
will later install the Helm chart and annotate the controller service account
with the Terraform output.

Required values from Terraform:

- `clusterName`
- `vpcId`
- `region`
- `serviceAccount.name`
- `serviceAccount.annotations.eks.amazonaws.com/role-arn`

The Argo CD Application lives at
`argocd/platform-addons/aws-load-balancer-controller.yaml`.

## NGINX Ingress Controller

NGINX receives HTTP traffic after it enters the cluster. The app chart uses:

```yaml
ingressClassName: nginx
```

That tells Kubernetes that the NGINX controller should handle the app Ingress.
The AWS Load Balancer exposes the NGINX controller; NGINX then routes requests
to the correct Kubernetes Service.

The Argo CD Application lives at `argocd/platform-addons/ingress-nginx.yaml`.

## ALB-to-NGINX bridge

The bridge Ingress lives at `k8s/platform/alb-to-nginx/ingress.yaml` and is
reconciled by `argocd/platform-addons/alb-to-nginx-bridge.yaml`.

It uses `ingressClassName: alb`, so AWS Load Balancer Controller owns it. Its
backend points at the `ingress-nginx-controller` Service. Application Ingress
objects still use `ingressClassName: nginx`.

This is the key distinction:

```text
alb Ingress   → creates AWS ALB and sends traffic to NGINX
nginx Ingress → routes HTTP traffic from NGINX to applications
```

## Metrics Server

Metrics Server provides pod and node resource metrics to the Kubernetes API.
The Horizontal Pod Autoscaler depends on these metrics to decide when to scale
the AI inference Deployment.

Without Metrics Server, the HPA object can exist, but it cannot make useful CPU
scaling decisions.

The Argo CD Application lives at `argocd/platform-addons/metrics-server.yaml`.

## External Secrets Operator

External Secrets Operator syncs approved AWS Secrets Manager values into
Kubernetes Secrets.

Terraform creates its IRSA role. Argo CD installs the operator from the pinned
Helm chart. The AI inference Helm chart creates the app-specific `SecretStore`
and `ExternalSecret`.

The Argo CD Application lives at `argocd/platform-addons/external-secrets.yaml`.

## Why not install add-ons with Terraform?

Terraform is excellent at managing AWS infrastructure. Argo CD is better for
continuous reconciliation of Kubernetes manifests and Helm releases.

If Terraform installs Helm releases and Argo CD also manages Kubernetes
resources, ownership becomes unclear. In production, unclear ownership causes
drift, failed upgrades, and surprise rollbacks.

This project keeps the boundary clean:

```text
Terraform → AWS prerequisites
Argo CD   → Kubernetes add-ons and applications
```
