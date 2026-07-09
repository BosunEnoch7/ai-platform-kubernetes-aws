# Alertmanager routing

Alertmanager is configured with an explicit routing tree, but no real external
receiver credentials are committed to Git.

## Routing model

```text
all alerts
→ platform-null

severity=critical
→ platform-critical

severity=warning
→ platform-warning
```

The initial receivers are intentionally empty. This lets the monitoring stack
start safely in a portfolio/dev environment without sending test alerts to real
people or systems.

## Why empty receivers are useful in dev

In production, every actionable alert should route to a real receiver. In a
portfolio environment, empty receivers are safer because they demonstrate the
routing shape without requiring Slack, PagerDuty, email, or webhook secrets.

## Production receiver examples

Production teams normally wire receivers to one or more of:

- PagerDuty for urgent incidents;
- Slack or Microsoft Teams for team visibility;
- email for low-urgency notifications;
- incident automation webhooks.

Receiver credentials should come from Kubernetes Secrets populated by External
Secrets Operator, not from Git.

## Grouping strategy

Alerts are grouped by:

- `alertname`
- `namespace`
- `service`

That keeps related symptoms together while still preserving useful ownership
context.

## Repeat intervals

Critical alerts repeat faster than warning alerts:

- critical: every `1h`;
- warning: every `4h`.

This reduces noise while keeping urgent incidents visible.
