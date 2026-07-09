import pytest
from ai_platform.main import create_app
from fastapi.testclient import TestClient
from prometheus_client import CollectorRegistry


@pytest.fixture
def client() -> TestClient:
    with TestClient(create_app(registry=CollectorRegistry())) as test_client:
        yield test_client
