# ADR 0018: Use CloudWatch Logs for container log shipping

## Status

Accepted

## Context

The platform needs centralized logs for application troubleshooting. The FastAPI
app already emits structured JSON logs to stdout. EKS nodes need a collector to
ship those logs to a durable backend.

## Decision

Use AWS for Fluent Bit to ship application container logs to CloudWatch Logs.

Terraform creates the log group, retention policy, and collector IRSA role.
Argo CD installs the collector through the AWS EKS Helm chart.

## Rationale

CloudWatch Logs is the native AWS logging backend and is familiar to reviewers
who expect EKS workloads to integrate with AWS operations tooling.

Using a node-level collector avoids embedding AWS log-writing logic in the app
and keeps application IAM smaller.

## Trade-offs

CloudWatch Logs is easy to operate in AWS, but it can become expensive with
high-volume logs or long retention. The baseline uses 30-day retention and
structured application logs to control cost and improve queryability.

## Consequences

- Application logs are centralized in CloudWatch Logs.
- The app continues writing to stdout/stderr.
- The collector uses IRSA instead of node-wide static credentials.
- Log retention is managed explicitly.
