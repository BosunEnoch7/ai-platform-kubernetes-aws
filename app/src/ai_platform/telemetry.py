"""Prometheus instruments with intentionally bounded labels."""

from dataclasses import dataclass
from time import perf_counter

from fastapi import Request, Response
from prometheus_client import CollectorRegistry, Counter, Histogram
from starlette.middleware.base import BaseHTTPMiddleware, RequestResponseEndpoint

KNOWN_ROUTES = {
    "/v1/inference",
    "/health/live",
    "/health/ready",
    "/metrics",
}


@dataclass(slots=True)
class Metrics:
    registry: CollectorRegistry
    requests: Counter
    latency: Histogram
    provider_failures: Counter

    @classmethod
    def create(cls, registry: CollectorRegistry | None = None) -> "Metrics":
        active_registry = registry or CollectorRegistry()
        return cls(
            registry=active_registry,
            requests=Counter(
                "http_requests_total",
                "Total HTTP requests.",
                ("method", "route", "status"),
                registry=active_registry,
            ),
            latency=Histogram(
                "http_request_duration_seconds",
                "HTTP request latency in seconds.",
                ("method", "route"),
                registry=active_registry,
            ),
            provider_failures=Counter(
                "inference_provider_failures_total",
                "Total inference provider failures.",
                ("provider",),
                registry=active_registry,
            ),
        )


class MetricsMiddleware(BaseHTTPMiddleware):
    def __init__(self, app: object, metrics: Metrics) -> None:
        super().__init__(app)
        self.metrics = metrics

    async def dispatch(
        self,
        request: Request,
        call_next: RequestResponseEndpoint,
    ) -> Response:
        route = request.url.path if request.url.path in KNOWN_ROUTES else "unmatched"
        started = perf_counter()
        status = 500
        try:
            response = await call_next(request)
            status = response.status_code
            return response
        finally:
            self.metrics.requests.labels(request.method, route, str(status)).inc()
            self.metrics.latency.labels(request.method, route).observe(
                perf_counter() - started
            )
