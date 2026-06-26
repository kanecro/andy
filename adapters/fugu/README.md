# Fugu Adapter for andy

This adapter describes how to use andy in a Fugu-first environment.

## Assumptions

- Fugu chooses models automatically.
- andy provides workflows, roles, policies, artifacts, and guardrails.
- Runtime-specific installation path is `${FUGU_HOME:-~/.fugu}`.

## Session bootstrap

1. Load `AGENTS.md`.
2. Load only the workflow needed for the current user request.
3. Load relevant policies.
4. Select roles by capability profile, not model name.
5. For implementation, assign explicit write scopes to workers.

## Important

andy intentionally avoids runtime-specific orchestration constructs in `core/`. If a runtime needs special commands or settings, generate or document them in `adapters/<runtime>/` rather than adding them to core.
