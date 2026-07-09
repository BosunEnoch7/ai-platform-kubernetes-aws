"""FastAPI application factory."""

import logging
from uuid import uuid4

from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse, Response
from prometheus_client import CONTENT_TYPE_LATEST, CollectorRegistry, generate_latest

from ai_platform import __version__
from ai_platform.config import Settings
from ai_platform.logging import configure_logging
from ai_platform.models import (
    ErrorDetail,
    ErrorResponse,
    HealthResponse,
    InferenceRequest,
    InferenceResponse,
)
from ai_platform.providers import (
    DeterministicProvider,
    InferenceProvider,
    ProviderUnavailableError,
)
from ai_platform.telemetry import Metrics, MetricsMiddleware

logger = logging.getLogger(__name__)


def create_app(
    provider: InferenceProvider | None = None,
    registry: CollectorRegistry | None = None,
    settings: Settings | None = None,
) -> FastAPI:
    active_settings = settings or Settings.from_environment()
    configure_logging(active_settings.log_level)

    if active_settings.provider_name != "deterministic" and provider is None:
        raise ValueError(f"Unsupported provider: {active_settings.provider_name}")

    app = FastAPI(
        title="AI Platform Inference API",
        version=__version__,
        docs_url="/docs",
        redoc_url=None,
    )
    app.state.provider = provider or DeterministicProvider()
    app.state.settings = active_settings
    app.state.metrics = Metrics.create(registry)
    app.add_middleware(MetricsMiddleware, metrics=app.state.metrics)

    @app.get("/health/live", response_model=HealthResponse, tags=["health"])
    async def liveness() -> HealthResponse:
        return HealthResponse(status="alive", service=active_settings.service_name)

    @app.get(
        "/health/ready",
        response_model=HealthResponse,
        responses={503: {"model": ErrorResponse}},
        tags=["health"],
    )
    async def readiness(request: Request) -> HealthResponse:
        request_id = request.headers.get("x-request-id") or str(uuid4())
        if not await app.state.provider.is_ready():
            return JSONResponse(
                status_code=503,
                content=ErrorResponse(
                    error=ErrorDetail(
                        code="provider_not_ready",
                        message="Inference provider is not ready.",
                    ),
                    request_id=request_id,
                ).model_dump(),
            )
        return HealthResponse(status="ready", service=active_settings.service_name)

    @app.post(
        "/v1/inference",
        response_model=InferenceResponse,
        responses={503: {"model": ErrorResponse}},
        tags=["inference"],
    )
    async def inference(
        payload: InferenceRequest,
        request: Request,
    ) -> InferenceResponse:
        request_id = request.headers.get("x-request-id") or str(uuid4())
        provider_name = app.state.provider.name
        try:
            output = await app.state.provider.generate(
                payload.prompt,
                payload.max_tokens,
            )
        except ProviderUnavailableError as error:
            app.state.metrics.provider_failures.labels(provider_name).inc()
            logger.warning(
                "Inference provider unavailable.",
                extra={"request_id": request_id, "provider": provider_name},
            )
            raise HTTPException(
                status_code=503,
                detail={
                    "code": "provider_unavailable",
                    "message": "Inference provider is temporarily unavailable.",
                    "request_id": request_id,
                },
            ) from error

        logger.info(
            "Inference request completed.",
            extra={"request_id": request_id, "provider": provider_name},
        )
        return InferenceResponse(
            request_id=request_id,
            provider=provider_name,
            output=output,
        )

    @app.get("/metrics", include_in_schema=False)
    async def metrics() -> Response:
        return Response(
            content=generate_latest(app.state.metrics.registry),
            media_type=CONTENT_TYPE_LATEST,
        )

    return app


app = create_app()
