# Codex-style Adapter

`AGENTS.md` is the canonical entrypoint for Codex-style runtimes.

## Recommended use

- Keep `AGENTS.md` at the repository root.
- For user-level installation, `./install.sh` symlinks it to `${CODEX_HOME:-~/.codex}/AGENTS.md` by default so Codex/codex-fugu sessions can load the harness:

```bash
./install.sh
```

Use `./install.sh --no-codex` only when you intentionally do not want to modify Codex's global entrypoint.

## Loading policy

Start with `AGENTS.md`, then load only the relevant `core/workflows/`, `core/policies/`, and `core/roles/` files for the current task.
