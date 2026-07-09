# Local container verification

This procedure verifies the same image contract that will later run on EKS.
Docker Desktop or another Linux container engine must be running.

## Build

From the repository root:

```powershell
docker build `
  --build-arg "BUILD_DATE=$((Get-Date).ToUniversalTime().ToString('o'))" `
  --build-arg "VCS_REF=$(git rev-parse --short HEAD)" `
  --build-arg "VERSION=0.1.0" `
  --tag ai-platform-api:0.1.0 `
  .
```

The builder installs only packages present in `requirements.lock`, verifies
their hashes, and accepts binary wheels only. The runtime stage receives the
virtual environment and application source, not build tools or package caches.

## Run

```powershell
docker run --rm `
  --name ai-platform-api `
  --publish 8080:8080 `
  --read-only `
  --cap-drop ALL `
  --security-opt no-new-privileges `
  ai-platform-api:0.1.0
```

The local command deliberately applies controls that Kubernetes will later
express through its container security context.

## Verify

In another terminal:

```powershell
Invoke-RestMethod http://localhost:8080/health/live
Invoke-RestMethod http://localhost:8080/health/ready

$body = @{
  prompt = "platform engineering matters"
  max_tokens = 128
} | ConvertTo-Json

Invoke-RestMethod `
  -Method Post `
  -Uri http://localhost:8080/v1/inference `
  -ContentType application/json `
  -Body $body

Invoke-WebRequest http://localhost:8080/metrics
```

## Inspect the runtime identity

```powershell
docker run --rm --entrypoint id ai-platform-api:0.1.0
```

The expected identity is UID and GID `10001`, not root.

## Why the Dockerfile has no `HEALTHCHECK`

EKS will own liveness and readiness decisions through separate Kubernetes
probes. A Docker health check can express only one aggregate status and would
duplicate probe timing in two places. Keeping health policy in the Helm chart
avoids conflicting restart and traffic-removal behavior.

## Why one Uvicorn worker

Kubernetes will scale replicas horizontally. One worker per container keeps
CPU and memory requests, shutdown behavior, Prometheus state, and HPA decisions
easy to reason about. Multiple workers can be evaluated later using measured
throughput rather than assumed efficiency.
