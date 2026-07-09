# ADR 0001: Use Amazon EKS as the platform runtime

- **Status:** Accepted
- **Date:** 2026-07-04

## Context

The project must demonstrate how AI workloads are operated rather than merely
hosted. Required capabilities include declarative deployment, workload
identity, health-based traffic management, autoscaling, rolling updates,
GitOps, and Kubernetes-native observability.

Simpler AWS runtimes could host one FastAPI service with less cost and
operational overhead, but they would hide much of the platform-engineering
surface this project is intended to demonstrate.

## Decision

Use Amazon EKS as the managed Kubernetes control plane. Run worker capacity in
private subnets across multiple Availability Zones and expose only explicitly
approved entry points.

## Consequences

### Benefits

- Demonstrates Kubernetes scheduling, networking, identity, delivery, and
  operations in one coherent system.
- Uses an AWS-managed, highly available Kubernetes control plane.
- Supports standard Kubernetes and CNCF tooling.

### Costs and risks

- EKS, worker capacity, NAT gateways, and load balancers incur ongoing cost.
- Cluster upgrades, add-ons, node capacity, and workload policies remain our
  responsibility.
- A single small API does not independently justify Kubernetes; the platform
  learning and portfolio objectives do.

## Guardrails

- Start with a development environment and explicit cost controls.
- Keep application logic small so platform decisions remain visible.
- Document how a simpler ECS or App Runner design would differ.
