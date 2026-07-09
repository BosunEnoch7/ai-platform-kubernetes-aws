# Monitoring foundation

This project uses Prometheus, Grafana, and Alertmanager through
`kube-prometheus-stack`.

## Signals collected from the AI API

The FastAPI app exposes `/metrics` with bounded Prometheus labels:

- `http_requests_total{method,route,status}`
- `http_request_duration_seconds{method,route}`
- `inference_provider_failures_total{provider}`

Bounded labels matter because unbounded labels such as raw URL paths, prompts,
request IDs, or user IDs can create high-cardinality metrics and overload
Prometheus.

## Kubernetes discovery

The app Helm chart creates:

- `ServiceMonitor` for scraping `/metrics`;
- `PrometheusRule` for alerting on error rate, latency, and provider failures.

The monitoring stack selects only objects labeled:

```yaml
monitoring.ai-platform/enabled: "true"
```

This prevents the platform Prometheus from scraping every ServiceMonitor in the
cluster by accident.

## Starter alerts

| Alert | Purpose |
|---|---|
| `AIInferenceHighErrorRate` | Detects elevated 5xx responses from `/v1/inference`. |
| `AIInferenceHighP95Latency` | Detects slow inference request handling. |
| `AIInferenceProviderFailures` | Detects provider-level failures. |

## Grafana dashboard

The starter dashboard lives at:

```text
k8s/monitoring/grafana-dashboards/ai-inference-dashboard.yaml
```

It includes panels for:

- inference request rate;
- 5xx error rate;
- provider failures;
- p95 latency;
- requests by status code.

## Production hardening

Before production use:

- provide the `grafana-admin` Kubernetes Secret from an external secret source;
- configure real Alertmanager receivers such as Slack, PagerDuty, or email;
- add persistent storage for Prometheus and Alertmanager;
- define retention based on cost and compliance;
- add black-box checks for public endpoints;
- add SLOs and burn-rate alerts.

See also:

- [Alertmanager routing](alertmanager-routing.md)
- [Grafana hardening](grafana-hardening.md)
