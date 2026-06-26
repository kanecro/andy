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
