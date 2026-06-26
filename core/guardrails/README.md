# Guardrails

Guardrails define deterministic checks that should not rely on LLM attention alone.

Each guardrail has:

- policy document in `core/guardrails/`
- optional executable script in `scripts/guardrails/`
- adapter mapping in `adapters/fugu/guardrail-map.md`
