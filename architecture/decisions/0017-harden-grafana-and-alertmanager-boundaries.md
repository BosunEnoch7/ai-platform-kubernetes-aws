# ADR 0017: Harden Grafana and Alertmanager boundaries

## Status

Accepted

## Context

The monitoring stack includes Grafana and Alertmanager. Both can easily drift
into unsafe defaults:

- Grafana can start with default or inline admin credentials;
- Alertmanager can contain webhook URLs or notification tokens in Git.

## Decision

Configure Grafana to use an existing Kubernetes Secret named `grafana-admin`.
Do not commit real Grafana admin credentials.

Configure Alertmanager with an explicit routing tree and empty placeholder
receivers. Real receiver credentials must be added through external secret
management before production use.

## Rationale

This demonstrates the operational structure without leaking credentials.
Credentials and notification tokens are runtime secrets, not source-code
configuration.

The routing tree remains visible and reviewable in Git, while sensitive receiver
details stay outside Git.

## Trade-offs

The monitoring stack will require a `grafana-admin` Secret before Grafana is
fully usable. This adds a bootstrap step, but it avoids relying on default
credentials.

Empty Alertmanager receivers are safe for development but not production-ready
until real receivers are configured.

## Consequences

- Grafana admin credentials are externalized.
- Alertmanager routing is documented and reviewable.
- Real notification integrations can be added later without changing the app
  monitoring rules.
