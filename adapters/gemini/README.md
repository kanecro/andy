# Gemini-style Adapter

`GEMINI.md` is a compatibility shim that imports `AGENTS.md`.

This adapter covers both **Gemini CLI** and **Gemini Antigravity**, which share the
same custom-command format.

## Recommended use

- Keep `AGENTS.md` canonical.
- Keep `GEMINI.md` thin.
- Load task-specific files from `core/` only as needed.

Optional user-level shim:

```bash
./install.sh --with-gemini
```

## Slash commands

Gemini custom commands live in `adapters/gemini/commands/*.toml` and are installed
into `~/.gemini/commands/` by `./install.sh --with-gemini`. They expose
`/brainstorm`, `/spec`, `/implement`, `/review`, `/test`, `/compound`, `/setup`, `/ship`.
Each command uses `{{args}}` and resolves the andy harness root itself, then loads
the matching `core/workflows/*.md` runbook. The current working directory is always
the target development repository.

Example:

```text
/brainstorm issue #123
/spec issue-123-add-notifications
```

### Antigravity note

Antigravity reuses the same `*.toml` command format. If your Antigravity build reads
commands from a different directory (for example `~/.gemini/antigravity-cli/` or a
project-level `.agents/`), copy or symlink `adapters/gemini/commands/*.toml` there.
The `AGENTS.md` routing layer remains the fallback for plain messages like
`brainstorm issue #123`.

The files under `adapters/gemini/commands/` are generated from
`adapters/commands/catalog.json`. Edit the catalog and run
`python3 scripts/generate-commands.py`; do not edit generated command files directly.
