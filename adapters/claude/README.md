# Claude-style Adapter

`CLAUDE.md` is a compatibility shim that imports `AGENTS.md`.

## Recommended use

- Keep `AGENTS.md` canonical.
- Keep `CLAUDE.md` thin.
- Do not add runtime-specific workflow policy to `CLAUDE.md`; put durable policy under `core/`.

Optional user-level shim:

```bash
./install.sh --with-claude
```

## Slash commands

Claude Code custom slash commands live in `adapters/claude/commands/*.md` and are
installed into `~/.claude/commands/` by `./install.sh --with-claude`. They expose
`/brainstorm`, `/spec`, `/implement`, `/review`, `/test`, `/compound`, `/setup`, `/ship`.
Each command uses `$ARGUMENTS` and resolves the andy harness root itself, then
loads the matching `core/workflows/*.md` runbook. The current working directory is
always the target development repository.

Example:

```text
/brainstorm issue #123
/spec issue-123-add-notifications
```

If a runtime cannot use these commands, the `AGENTS.md` routing layer still
handles a plain message like `brainstorm issue #123`.

The files under `adapters/claude/commands/` are generated from
`adapters/commands/catalog.json`. Edit the catalog and run
`python3 scripts/generate-commands.py`; do not edit generated command files directly.
