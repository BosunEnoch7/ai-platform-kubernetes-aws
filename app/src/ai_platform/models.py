"""Public request and response schemas."""

from pydantic import BaseModel, Field


class InferenceRequest(BaseModel):
    prompt: str = Field(min_length=1, max_length=4_000)
    max_tokens: int = Field(default=128, ge=1, le=1_024)


class InferenceResponse(BaseModel):
    request_id: str
    provider: str
    output: str


class HealthResponse(BaseModel):
    status: str
    service: str


class ErrorDetail(BaseModel):
    code: str
    message: str


class ErrorResponse(BaseModel):
    error: ErrorDetail
    request_id: str
