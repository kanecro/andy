# Gemini-style Adapter

`GEMINI.md` is a compatibility shim that imports `AGENTS.md`.

## Recommended use

- Keep `AGENTS.md` canonical.
- Keep `GEMINI.md` thin.
- Load task-specific files from `core/` only as needed.

Optional user-level shim:

```bash
./install.sh --with-gemini
```
