# Codex-style Adapter

`AGENTS.md` is the canonical entrypoint for Codex-style runtimes.

## Recommended use

- Keep `AGENTS.md` at the repository root.
- For user-level installation, `./install.sh` installs the harness under `${CODEX_HOME:-~/.codex}` and symlinks `${CODEX_HOME:-~/.codex}/AGENTS.md` so Codex/codex-fugu sessions can load it:

```bash
./install.sh
```

## Loading policy

Start with `AGENTS.md`, then load only the relevant `core/workflows/`, `core/policies/`, and `core/roles/` files for the current task.

For short commands such as `brainstorm issue #123`, load `core/workflows/command-router.md` first and resolve the installed harness via `core/policies/harness-resolution-policy.md`. The current working directory remains the target project; the installed harness is only the source of instructions.

## Slash commands

Codex / codex-fugu custom prompts live in `adapters/codex/prompts/*.md` and are
installed into `${CODEX_HOME:-~/.codex}/prompts/` by default. They expose
`/brainstorm`, `/spec`, `/implement`, `/review`, `/test`, `/compound`, `/setup`, `/ship` in
every repository. Each prompt uses `$ARGUMENTS` and resolves the harness root
itself. See `adapters/codex/prompts/README.md`.
