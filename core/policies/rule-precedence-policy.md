# Rule Precedence Policy

andy separates rules into **immutable rules** and **overrideable rules**.

## Precedence order

When instructions conflict, apply them in this order:

1. Runtime / platform / system instructions
2. The user's current explicit request
3. andy immutable rules: `core/policies/immutable-rules.md`
4. Project overrides: project `AGENTS.md`, `.andy/overrides.md`, or equivalent project docs
5. andy default workflows / roles / skills / artifact schemas
6. General model knowledge and style preferences

## Important interpretation

- Project overrides may specialize andy's defaults, but must not weaken immutable rules.
- User approval can authorize a normally blocked action only when the immutable rule defines it as approval-gated.
- If a project override conflicts with an immutable rule, follow the immutable rule and mention the conflict briefly.
- If two project-level instructions conflict, prefer the more local/specific instruction and ask the user if risk is high.

## Examples

| Project override says | Immutable rule says | Result |
|---|---|---|
| "Skip tests for speed" | Evidence before claims | Do not claim completion without verification; if tests cannot run, report risk |
| "Use force push during release" | Force push requires explicit confirmation | Ask before force push |
| "Edit any file as needed" | Parallel workers need write ownership | Assign write scope before parallel edits |
| "Read `.env` for config" | Do not read secrets | Do not read `.env`; ask user for non-secret values |
