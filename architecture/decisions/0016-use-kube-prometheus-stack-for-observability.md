# ADR 0016: Use kube-prometheus-stack for observability

## Status

Accepted

## Context

The platform needs metrics collection, dashboards, and alerting. The requested
stack includes Prometheus, Grafana, and Alertmanager.

Installing those components independently increases configuration burden and
misses Kubernetes-native custom resources such as `ServiceMonitor` and
`PrometheusRule`.

## Decision

Use the Prometheus Community `kube-prometheus-stack` Helm chart as the
monitoring foundation.

Application metrics discovery and alerts are owned by the application Helm
chart through `ServiceMonitor` and `PrometheusRule` resources.

## Rationale

`kube-prometheus-stack` is a common production-inspired baseline. It provides
Prometheus Operator, Prometheus, Grafana, Alertmanager, and Kubernetes alerting
CRDs in one managed chart.

The app chart owns its own scrape and alert definitions because the app team
understands the app metrics best.

## Trade-offs

The stack is heavier than a single Prometheus deployment. For small demos it can
feel large, but it better reflects how Kubernetes observability is commonly
operated.

The initial chart version is left as an explicit replacement placeholder because
the large upstream chart index timed out in this environment. It must be pinned
before cluster apply.

## Consequences

- Prometheus discovers the AI app through ServiceMonitor.
- Alertmanager receives app-specific PrometheusRule alerts.
- Grafana can load dashboard ConfigMaps through its sidecar.
- Monitoring resources remain GitOps-managed.
