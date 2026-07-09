from ai_platform.main import create_app
from fastapi.testclient import TestClient
from prometheus_client import CollectorRegistry


class NotReadyProvider:
    name = "not-ready"

    async def generate(self, prompt: str, max_tokens: int) -> str:
        return prompt[:max_tokens]

    async def is_ready(self) -> bool:
        return False


def test_liveness_does_not_depend_on_provider(client: TestClient) -> None:
    response = client.get("/health/live")

    assert response.status_code == 200
    assert response.json()["status"] == "alive"


def test_readiness_reports_healthy_provider(client: TestClient) -> None:
    response = client.get("/health/ready")

    assert response.status_code == 200
    assert response.json()["status"] == "ready"


def test_readiness_rejects_traffic_when_provider_is_unavailable() -> None:
    application = create_app(
        provider=NotReadyProvider(),
        registry=CollectorRegistry(),
    )

    with TestClient(application) as client:
        response = client.get("/health/ready", headers={"x-request-id": "health-1"})

    assert response.status_code == 503
    assert response.json()["error"]["code"] == "provider_not_ready"
    assert response.json()["request_id"] == "health-1"
