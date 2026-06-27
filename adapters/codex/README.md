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
