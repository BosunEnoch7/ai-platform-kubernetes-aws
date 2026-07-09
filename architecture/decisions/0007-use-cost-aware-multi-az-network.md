# ADR 0007: Use a cost-aware multi-AZ VPC

- **Status:** Accepted
- **Date:** 2026-07-04

## Context

EKS requires resilient networking, but NAT gateways and interface endpoints
can dominate the cost of a small portfolio environment. A production topology
and a continuously running development topology should not be assumed to have
the same cost tolerance.

Worker nodes must not receive public addresses. Internet-facing load balancers
still require correctly tagged public subnets.

## Decision

Create public and private subnets in three Availability Zones. Place worker
nodes in private subnets and reserve public subnets for internet-facing load
balancers and NAT gateways.

Support two explicit NAT modes:

- `single` for the development portfolio baseline;
- `per_az` for production resilience.

Enable the S3 gateway endpoint by default. Make paid ECR, STS, and CloudWatch
Logs interface endpoints optional and enable them only after evaluating
security requirements and measured traffic costs.

## Consequences

### Benefits

- EKS can distribute workloads across three failure domains.
- Worker nodes have no direct inbound internet exposure.
- The same module can demonstrate cost-optimized and resilient egress.
- VPC Flow Logs provide network-level audit and troubleshooting evidence.

### Costs and risks

- A single NAT gateway creates a development AZ dependency.
- Cross-AZ egress through that gateway can add data-transfer cost.
- Per-AZ NAT and interface endpoints add significant fixed hourly cost.
- Flow Logs create ingestion and retention charges.

## Guardrails

- Never label the single-NAT mode highly available.
- Use `per_az` in the documented production configuration.
- Review NAT bytes and endpoint pricing before enabling every endpoint.
- Keep EKS nodes in private subnets with public IP assignment disabled.
