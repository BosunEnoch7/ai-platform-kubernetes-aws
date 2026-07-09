# syntax=docker/dockerfile:1.7

ARG PYTHON_IMAGE=python:3.12.10-slim-bookworm

FROM ${PYTHON_IMAGE} AS builder

ENV PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    VIRTUAL_ENV=/opt/venv

RUN python -m venv "${VIRTUAL_ENV}"
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

COPY requirements.lock /tmp/requirements.lock
RUN python -m pip install \
      --require-hashes \
      --no-deps \
      --only-binary=:all: \
      --requirement /tmp/requirements.lock

FROM ${PYTHON_IMAGE} AS runtime

ARG BUILD_DATE="unknown"
ARG VCS_REF="unknown"
ARG VERSION="0.1.0"

LABEL org.opencontainers.image.title="AI Platform Inference API" \
      org.opencontainers.image.description="Inference workload for the EKS AI platform" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.version="${VERSION}"

ENV APP_ENVIRONMENT=production \
    APP_LOG_LEVEL=INFO \
    APP_PROVIDER=deterministic \
    PATH="/opt/venv/bin:${PATH}" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app

RUN groupadd --gid 10001 app \
    && useradd \
      --uid 10001 \
      --gid 10001 \
      --no-create-home \
      --shell /usr/sbin/nologin \
      app

COPY --from=builder /opt/venv /opt/venv
COPY --chown=10001:10001 app/src/ai_platform /app/ai_platform

USER 10001:10001
WORKDIR /app

EXPOSE 8080

CMD ["uvicorn", "ai_platform.main:app", "--host=0.0.0.0", "--port=8080", "--workers=1", "--timeout-keep-alive=5", "--timeout-graceful-shutdown=30", "--no-access-log"]
