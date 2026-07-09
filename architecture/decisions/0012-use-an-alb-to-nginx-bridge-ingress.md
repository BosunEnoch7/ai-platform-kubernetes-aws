# ADR 0012: Use an ALB-to-NGINX bridge Ingress

## Status

Accepted

## Context

The project architecture intentionally includes both AWS Load Balancer
Controller and NGINX Ingress Controller. The AWS controller integrates
Kubernetes with AWS load balancers. NGINX provides Kubernetes-native HTTP
routing inside the cluster.

Using only one of them would be simpler, but the portfolio goal is to
demonstrate both cloud load-balancer integration and in-cluster ingress
operations.

## Decision

Create a platform-owned Kubernetes Ingress named `alb-to-nginx` with
`ingressClassName: alb`.

AWS Load Balancer Controller reconciles that Ingress into an internet-facing
Application Load Balancer. The ALB forwards traffic to the
`ingress-nginx-controller` Service. Application Ingress objects continue to use
`ingressClassName: nginx`.

## Rationale

This creates a clear boundary:

- the platform bridge owns AWS-facing entry;
- NGINX owns in-cluster HTTP routing;
- the application chart owns app host/path rules.

The bridge uses ALB target type `ip` so traffic can reach NGINX controller pods
through the ClusterIP Service endpoints without requiring a public NGINX
LoadBalancer Service.

## Trade-offs

The design adds a network hop, additional health checks, and more troubleshooting
surface. For one simple API, direct ALB-to-app routing would be cheaper and
simpler.

The extra layer is accepted because the project is designed to demonstrate
production platform patterns and trade-off awareness.

## Consequences

- NGINX remains internal to the cluster.
- AWS-facing load balancer settings are isolated in a platform manifest.
- HTTPS, WAF, access logs, and stricter CIDR controls can be added later without
  changing the app chart.
