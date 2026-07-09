# Inference application

This is a deliberately small FastAPI service. Its job is to provide a credible
workload for the platform without turning this repository into another
model-development project.

## API contract

| Endpoint | Purpose |
|---|---|
| `POST /v1/inference` | Run inference through the configured provider |
| `GET /health/live` | Confirm that the process and event loop are alive |
| `GET /health/ready` | Confirm that the provider can serve requests |
| `GET /metrics` | Expose Prometheus metrics |

The default provider is deterministic and requires no external credentials.
Production provider adapters will be added only when their secret, timeout,
retry, and failure behavior can be tested explicitly.

## Dependency policy

`pyproject.toml` expresses acceptable dependency ranges for development.
`requirements.lock` records the exact, hash-verified production dependency
graph used by the container. Regenerate the lock intentionally with:

```powershell
python -m piptools compile pyproject.toml `
  --output-file requirements.lock `
  --generate-hashes `
  --strip-extras
```

## Safety and observability boundaries

- Prompts are validated but never written to application logs or metric labels.
- Request IDs support correlation but are not metric labels.
- Provider names and endpoint names are bounded metric dimensions.
- Readiness can fail without causing Kubernetes to restart a healthy process.
- Provider failures return a stable platform error instead of exposing an
  upstream exception.
