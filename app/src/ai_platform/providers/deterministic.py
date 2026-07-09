"""A zero-cost provider for tests and platform verification."""


class DeterministicProvider:
    @property
    def name(self) -> str:
        return "deterministic"

    async def generate(self, prompt: str, max_tokens: int) -> str:
        words = prompt.split()
        return " ".join(reversed(words))[:max_tokens]

    async def is_ready(self) -> bool:
        return True
