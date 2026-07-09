"""Provider boundary used by the HTTP application."""

from typing import Protocol


class ProviderUnavailableError(RuntimeError):
    """A safe, provider-independent upstream failure."""


class InferenceProvider(Protocol):
    @property
    def name(self) -> str:
        """Return a bounded provider identifier."""

    async def generate(self, prompt: str, max_tokens: int) -> str:
        """Generate an inference response."""

    async def is_ready(self) -> bool:
        """Return whether this provider can currently serve traffic."""
