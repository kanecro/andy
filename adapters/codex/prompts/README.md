# andy Codex prompts (codex / codex-fugu slash commands)

These Markdown files become codex / codex-fugu custom prompts. After install, each
file `adapters/codex/prompts/<name>.md` is available in any repository as the slash
command `/<name>`, for example:

```text
/brainstorm issue #123
/spec issue-123-add-notifications
/implement issue-123-add-notifications
/ship issue #123
```

## How they work

- `install.sh` symlinks each file into `${CODEX_HOME:-~/.codex}/prompts/` by default.
- Codex scans only the top-level Markdown files in `${CODEX_HOME:-~/.codex}/prompts/`.
- `$ARGUMENTS` in each prompt receives everything typed after the command.
- Each prompt resolves the installed andy harness root, then loads the matching
  `core/workflows/*.md` runbook and follows it. The current working directory is
  always the target development repository.

## Other runtimes

The same workflow commands are provided per runtime, each in that runtime's own
command format:

- Claude Code: `adapters/claude/commands/*.md` → `~/.claude/commands/` (`--with-claude`)
- Gemini CLI / Antigravity: `adapters/gemini/commands/*.toml` → `~/.gemini/commands/` (`--with-gemini`)

## Source of truth

The prompt files in this directory are generated. Edit
`adapters/commands/catalog.json`, then run:

```bash
python3 scripts/generate-commands.py
```

## Why both prompts and AGENTS.md routing exist

- The `/command` prompts give a deterministic, low-friction entry point that works
  the same in every repository, even when a project has its own `AGENTS.md`.
- The `AGENTS.md` "Short Workflow Commands" section is the fallback: it lets a
  plain message like `brainstorm issue #123` (no slash) still route correctly.

## Note on deprecation

OpenAI now recommends skills over custom prompts for reusable instructions. andy
keeps these prompts because they are the simplest way to expose `/command`-style
entry points to codex-fugu today. If your runtime drops custom-prompt support,
the `AGENTS.md` routing layer still provides the same workflows.
