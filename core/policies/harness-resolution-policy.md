# Policy: harness-resolution

Use this policy whenever an andy workflow file, role, policy, skill, or artifact schema must be loaded.

## Goal

Find the installed andy harness consistently from any target development repository.

## Resolution order

Use the first directory that exists and contains both `AGENTS.md` and `core/workflows/`:

1. The directory containing the currently loaded andy `AGENTS.md`, when known.
2. `$ANDY_HARNESS_ROOT`, when set.
3. `${CODEX_HOME:-$HOME/.codex}/active-harness`.
4. `${CODEX_HOME:-$HOME/.codex}/harnesses/andy`.
5. `./.andy/harness`, only when the target project intentionally vendors the harness.

If none can be found, ask the user to run the andy installer or provide `ANDY_HARNESS_ROOT`.

## Path rules

- Treat paths under the resolved harness root as read-only harness instructions unless the user explicitly asks to edit andy itself.
- Treat the current working directory as the target project for code, specs, and generated artifacts.
- Do not resolve `core/workflows/...` relative to the target project unless the target project has explicitly vendored andy under `./.andy/harness`.
- Prefer referring to workflow files by role and command in user-facing text, not by long absolute paths.

## Quick shell probe

When file access is needed, this probe identifies the default installed harness root:

```bash
for dir in "${ANDY_HARNESS_ROOT:-}" "${CODEX_HOME:-$HOME/.codex}/active-harness" "${CODEX_HOME:-$HOME/.codex}/harnesses/andy" "./.andy/harness"; do
  [ -n "$dir" ] && [ -f "$dir/AGENTS.md" ] && [ -d "$dir/core/workflows" ] && printf '%s\n' "$dir" && break
done
```
