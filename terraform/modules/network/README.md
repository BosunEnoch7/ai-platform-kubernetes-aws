# Network module

This module creates the network boundary for EKS:

- one VPC with DNS support;
- public and private subnets across two or three Availability Zones;
- an internet gateway for public load balancers;
- configurable single or per-AZ NAT gateways for private workloads;
- an S3 gateway endpoint;
- optional ECR, STS, and CloudWatch Logs interface endpoints;
- optional VPC Flow Logs; and
- a locked-down default security group.

## Public does not mean every resource is public

A public subnet has a route to an internet gateway. Instances are not assigned
public IPv4 addresses automatically. Internet-facing load balancers use public
subnets; EKS worker nodes use private subnets.

## NAT modes

| Mode | Cost | Availability | Intended use |
|---|---:|---|---|
| `single` | One NAT gateway | Depends on one AZ; cross-AZ traffic is possible | Portfolio development |
| `per_az` | One per AZ | Each private subnet has an AZ-local path | Production baseline |

NAT gateways are managed services but remain zonal. A single NAT gateway is a
deliberate cost optimization, not a highly available design.

## VPC endpoints

The S3 gateway endpoint is enabled by default because it has no hourly endpoint
charge and ECR image layers are stored in S3. Interface endpoints are optional:
they can reduce NAT exposure and data processing but charge per endpoint, per
AZ, per hour.
