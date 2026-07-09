# Grafana hardening

Grafana is enabled through `kube-prometheus-stack`, but the chart is configured
to expect its admin credentials from an existing Kubernetes Secret.

## Expected secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: grafana-admin
  namespace: monitoring
type: Opaque
stringData:
  admin-user: replace-outside-git
  admin-password: replace-outside-git
```

Do not commit the real Secret manifest.

## Recommended source of truth

Store the real Grafana admin credentials in AWS Secrets Manager and project them
into Kubernetes with External Secrets Operator.

The secret shape should produce:

- `admin-user`
- `admin-password`

## Why not use default credentials

Default Grafana credentials are convenient for local demos, but they are unsafe
for shared environments. A portfolio project should show that admin credentials
are treated as secrets from the beginning.

## Production improvements

Before production use:

- enable SSO/OIDC for Grafana login;
- disable basic admin login after SSO is configured;
- restrict Grafana ingress to trusted users or VPN;
- enable dashboard provisioning through Git;
- back up dashboard definitions;
- audit dashboard and data source permissions.
