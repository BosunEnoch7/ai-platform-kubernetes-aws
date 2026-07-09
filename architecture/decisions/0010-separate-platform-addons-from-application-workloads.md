# ADR 0010: Separate platform add-ons from application workloads

## Status

Accepted

## Context

The AI inference API needs cluster capabilities around it:

- AWS Load Balancer Controller for AWS load balancer reconciliation;
- NGINX Ingress Controller for HTTP routing inside the cluster;
- Metrics Server for Horizontal Pod Autoscaler resource metrics;
- observability add-ons for metrics, dashboards, alerts, and logs.

These components are not owned by a single application. They are shared
platform services.

## Decision

Keep platform add-on AWS resources in a dedicated Terraform module named
`platform_addons`.

Terraform will create durable AWS-side prerequisites such as IAM roles and
policies. Kubernetes installation and reconciliation of the add-ons will be
owned by Argo CD in a later phase.

## Rationale

Separating platform add-ons from application workloads prevents accidental
coupling:

- deleting the AI app should not delete shared ingress infrastructure;
- upgrading NGINX should not require changing the app chart;
- AWS IAM roles for controllers should be reviewed separately from workload IAM;
- Argo CD can reconcile Kubernetes resources while Terraform owns AWS resources.

## Trade-offs

This introduces more files and modules, but the ownership boundary is cleaner.
The alternative is simpler early on, but it becomes fragile when more workloads
or environments are added.

## Consequences

- The application Helm chart stays focused on the FastAPI workload.
- Shared controllers get their own IAM and documentation.
- Later GitOps phases can install platform add-ons without giving Terraform
  ownership of Kubernetes releases.
