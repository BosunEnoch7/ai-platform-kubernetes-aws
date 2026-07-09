# ADR 0011: Use Argo CD Applications for platform add-ons

## Status

Accepted

## Context

The platform needs shared Kubernetes controllers such as AWS Load Balancer
Controller, ingress-nginx, and Metrics Server. These controllers are installed
with Helm charts, but the project also needs continuous reconciliation and
clear operational visibility.

## Decision

Represent each platform add-on as an Argo CD `Application`.

Use an app-of-apps manifest named `platform-addons` to point Argo CD at the
directory containing the individual add-on Applications.

## Rationale

Argo CD makes the desired add-on state visible and auditable. A reviewer can see
the chart source, chart version, namespace, Helm values, and sync policy in Git.

Each add-on remains independently upgradeable, while the app-of-apps pattern
gives operators a single bootstrap entry point.

## Trade-offs

The app-of-apps pattern introduces another layer to understand. For a very
small project, applying three Applications manually is simpler. For a portfolio
that demonstrates platform engineering, the explicit hierarchy is worth it.

## Consequences

- Terraform creates AWS prerequisites.
- Argo CD installs and reconciles Kubernetes add-ons.
- Chart versions are pinned instead of floating.
- Placeholder account-specific values must be replaced before applying to a
  real cluster.
