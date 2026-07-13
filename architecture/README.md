# Architecture

This directory is the source of truth for system structure and significant
engineering decisions.

## Contents

- `decisions/`: Architecture Decision Records (ADRs). These preserve the
  context, decision, trade-offs, and consequences behind the design.
- `diagrams/`: source-controlled architecture, delivery-flow, and observability
  diagrams.
- `threat-model/`: assets, trust boundaries, threats, and mitigations. Added
  alongside the security implementation.

## Diagrams

- [System architecture](diagrams/system-architecture.md)
- [Delivery flow](diagrams/delivery-flow.md)
- [Observability flow](diagrams/observability-flow.md)

## Architectural principle

Application traffic, software delivery, security, and observability are
separate planes. This prevents monitoring systems from being represented as
part of the synchronous inference request path and makes ownership and failure
boundaries easier to reason about.
