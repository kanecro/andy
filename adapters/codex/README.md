# Codex-style Adapter

`AGENTS.md` is the canonical entrypoint for Codex-style runtimes.

## Recommended use

- Keep `AGENTS.md` at the repository root.
- For user-level installation, optionally symlink it to `${CODEX_HOME:-~/.codex}/AGENTS.md` with:

```bash
./install.sh --with-codex
```

## Loading policy

Start with `AGENTS.md`, then load only the relevant `core/workflows/`, `core/policies/`, and `core/roles/` files for the current task.
