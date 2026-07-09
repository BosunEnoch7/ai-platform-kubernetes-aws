# ADR 0004: Use an ALB-to-NGINX ingress path for the portfolio baseline

- **Status:** Accepted
- **Date:** 2026-07-04

## Context

The requested stack includes both AWS Load Balancer Controller and NGINX
Ingress. Either can provide a simpler ingress design alone, so using both adds
latency, cost, configuration, and another failure boundary.

The portfolio also needs to demonstrate the difference between AWS edge
integration and Kubernetes-level routing policy.

## Decision

For the baseline architecture, use AWS Load Balancer Controller to provision an
internet-facing Application Load Balancer. The ALB forwards approved traffic
to the NGINX Ingress Controller service. NGINX applies Kubernetes routing rules
and forwards requests to the inference service.

The exact target mode and health-check behavior will be selected and tested
during the ingress phase.

## Consequences

### Benefits

- Separates AWS-facing traffic management from in-cluster routing policy.
- Demonstrates ALB integration and NGINX capabilities in one project.
- Leaves room for route-level controls such as rate limits and rewrites.

### Costs and risks

- Adds a network hop and two layers of health checking.
- Increases operational complexity and debugging surface.
- Is more expensive and may be unnecessary for one API.

## Alternatives

- Use ALB Ingress directly and remove NGINX.
- Expose NGINX through a Network Load Balancer.

These alternatives are preferable when simplicity, latency, or cost outweighs
the portfolio requirement. The baseline must include measurements and a
documented simplification path rather than claiming the extra layer is free.
