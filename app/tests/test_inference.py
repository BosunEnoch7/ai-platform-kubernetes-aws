from ai_platform.main import create_app
from ai_platform.providers import ProviderUnavailableError
from fastapi.testclient import TestClient
from prometheus_client import CollectorRegistry


class FailingProvider:
    name = "failing"

    async def generate(self, prompt: str, max_tokens: int) -> str:
        raise ProviderUnavailableError

    async def is_ready(self) -> bool:
        return True


def test_inference_uses_deterministic_provider(client: TestClient) -> None:
    response = client.post(
        "/v1/inference",
        json={"prompt": "platform engineering matters", "max_tokens": 128},
        headers={"x-request-id": "request-1"},
    )

    assert response.status_code == 200
    assert response.json() == {
        "request_id": "request-1",
        "provider": "deterministic",
        "output": "matters engineering platform",
    }


def test_inference_rejects_empty_prompt(client: TestClient) -> None:
    response = client.post("/v1/inference", json={"prompt": ""})

    assert response.status_code == 422


def test_provider_failure_uses_stable_external_error() -> None:
    application = create_app(
        provider=FailingProvider(),
        registry=CollectorRegistry(),
    )

    with TestClient(application) as client:
        response = client.post(
            "/v1/inference",
            json={"prompt": "hello"},
            headers={"x-request-id": "request-2"},
        )

    assert response.status_code == 503
    assert response.json()["detail"] == {
        "code": "provider_unavailable",
        "message": "Inference provider is temporarily unavailable.",
        "request_id": "request-2",
    }


def test_metrics_do_not_contain_prompt_or_request_id(client: TestClient) -> None:
    secret_prompt = "private-customer-prompt"
    request_id = "sensitive-request-id"
    client.post(
        "/v1/inference",
        json={"prompt": secret_prompt},
        headers={"x-request-id": request_id},
    )

    metrics = client.get("/metrics").text

    expected_metric = (
        'http_requests_total{method="POST",route="/v1/inference",status="200"}'
    )
    assert expected_metric in metrics
    assert secret_prompt not in metrics
    assert request_id not in metrics
