# ADR 0008: Use EKS managed node groups for the baseline

## Status

Accepted

## Context

The platform needs worker compute for API pods, ingress controllers, monitoring,
and GitOps controllers. The worker layer should be understandable, stable, and
portfolio-friendly before we introduce more advanced autoscaling choices.

## Decision

Use Amazon EKS managed node groups for the baseline cluster.

The development environment starts with one small On-Demand managed node group
running in private subnets.

## Why

Managed node groups give us a production-realistic EC2 worker model while
letting EKS handle the basic lifecycle operations: provisioning, updates,
terminations, and Kubernetes node draining.

This is the right baseline because it teaches the relationship between EKS,
EC2, Auto Scaling Groups, IAM, private subnets, and Kubernetes scheduling.

## Trade-offs

- Managed node groups are easier to explain than Karpenter at the start, but
  less flexible for advanced workload-driven provisioning.
- On-Demand nodes cost more than Spot, but they make demos and controller
  workloads more stable.
- A single general-purpose node group is simple, but production platforms often
  split system, ingress, workload, Spot, GPU, or tenant-specific node groups.

## Consequences

- The baseline cluster can run the platform components reliably.
- Later phases can add HPA for pods without also solving node autoscaling.
- Future improvements can introduce Karpenter, Spot pools, or specialized node
  groups as a deliberate evolution.
