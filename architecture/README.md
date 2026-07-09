# Architecture

This directory is the source of truth for system structure and significant
engineering decisions.

## Contents

- `decisions/`: Architecture Decision Records (ADRs). These preserve the
  context, decision, trade-offs, and consequences behind the design.
- `diagrams/`: source-controlled architecture, request-flow, delivery-flow,
  and observability diagrams. Added in a later phase.
- `threat-model/`: assets, trust boundaries, threats, and mitigations. Added
  alongside the security implementation.

## Architectural principle

Application traffic, software delivery, security, and observability are
separate planes. This prevents monitoring systems from being represented as
part of the synchronous inference request path and makes ownership and failure
boundaries easier to reason about.
