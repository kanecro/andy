# Fugu Adapter for andy

This adapter describes how to use andy in a Fugu-first environment.

## Assumptions

- Fugu chooses models automatically.
- Fugu/codex-fugu is Codex-compatible for harness loading.
- andy provides workflows, roles, policies, artifacts, and guardrails.
- The user-level installation path is `${CODEX_HOME:-~/.codex}`.

## Session bootstrap

1. Load `AGENTS.md`.
2. If the request starts with a short workflow command such as `brainstorm issue #123`, load `core/workflows/command-router.md`.
3. Resolve the installed harness root with `core/policies/harness-resolution-policy.md`; do not look for `core/workflows/` in the target repository unless it vendors andy.
4. Load only the workflow needed for the current user request.
5. Load relevant policies.
6. Treat the current working directory as the target project for artifacts and code changes.
7. Select roles by capability profile, not model name.
8. For implementation, assign explicit write scopes to workers.

## Short commands

After user-level install, andy installs custom prompts into `${CODEX_HOME:-~/.codex}/prompts/`,
so these slash commands work directly in any codex-fugu session and in any repository:

```text
/brainstorm issue #123
/spec <change-name>
/implement <change-name>
/review <change-name>
/test <change-name>
/ship issue #123
```

The same intents also work as plain messages (no slash) via the `AGENTS.md` router:

```text
brainstorm issue #123
brainstorm owner/repo#123
spec <change-name>
implement <change-name>
review <change-name>
test <change-name>
ship issue #123
```

For issue commands, prefer `gh issue view` in the target repository. If the issue cannot be fetched, ask for the issue text or the missing access step.

## Important

andy intentionally avoids runtime-specific orchestration constructs in `core/`. If a runtime needs special commands or settings, generate or document them in `adapters/<runtime>/` rather than adding them to core.
