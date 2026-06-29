# Adapters

Adapters explain how different agent runtimes should consume the same andy core harness.

`AGENTS.md` is canonical. Adapter files should not duplicate policy unless the runtime requires a shim.

## Workflow commands per runtime

`core/` stays runtime-neutral. Each runtime's `/brainstorm`, `/spec`, `/implement`,
`/review`, `/test`, `/compound`, `/setup`, `/ship` command is defined in its own adapter, in
that runtime's native command format:

| Runtime | Command files | Installed to | Format |
|---|---|---|---|
| Codex / codex-fugu | `adapters/codex/prompts/*.md` | `~/.codex/prompts/` | Markdown + `$ARGUMENTS` |
| Claude Code | `adapters/claude/commands/*.md` | `~/.claude/commands/` | Markdown + `$ARGUMENTS` |
| Gemini CLI / Antigravity | `adapters/gemini/commands/*.toml` | `~/.gemini/commands/` | TOML + `{{args}}` |

Gemini and Antigravity share one adapter because they use the same command format.
Every command resolves the installed andy harness root and then follows the shared
`core/workflows/*.md` runbooks, so behavior stays identical across runtimes.

## Generated command adapters

Do not edit runtime command files directly. They are generated from the shared
catalog:

```text
adapters/commands/catalog.json
```

Regenerate after changing the catalog:

```bash
python3 scripts/generate-commands.py
```

CI / validation should use:

```bash
python3 scripts/generate-commands.py --check
```
