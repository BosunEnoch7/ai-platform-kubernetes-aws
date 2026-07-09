"""Environment-backed application configuration."""

import os
from dataclasses import dataclass

DEFAULT_SERVICE_NAME = "ai-platform-api"
DEFAULT_ENVIRONMENT = "development"
DEFAULT_LOG_LEVEL = "INFO"
DEFAULT_PROVIDER_NAME = "deterministic"


@dataclass(frozen=True, slots=True)
class Settings:
    service_name: str = DEFAULT_SERVICE_NAME
    environment: str = DEFAULT_ENVIRONMENT
    log_level: str = DEFAULT_LOG_LEVEL
    provider_name: str = DEFAULT_PROVIDER_NAME

    @classmethod
    def from_environment(cls) -> "Settings":
        return cls(
            service_name=os.getenv("APP_SERVICE_NAME", DEFAULT_SERVICE_NAME),
            environment=os.getenv("APP_ENVIRONMENT", DEFAULT_ENVIRONMENT),
            log_level=os.getenv("APP_LOG_LEVEL", DEFAULT_LOG_LEVEL).upper(),
            provider_name=os.getenv("APP_PROVIDER", DEFAULT_PROVIDER_NAME),
        )
