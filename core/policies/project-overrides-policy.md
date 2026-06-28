# Project Overrides Policy

Project overrides customize andy for a specific repository or product. They are intended to add local knowledge, not to weaken global safety or quality invariants.

## Recommended project override locations

Use the first applicable file that exists:

1. `<project>/AGENTS.md` — cross-agent project instructions
2. `<project>/.andy/overrides.md` — andy-specific project overrides
3. `<project>/.andy/workflows.md` — workflow customizations
4. `<project>/.andy/verification.md` — project commands and quality gates
5. Runtime-specific shims such as `CLAUDE.md` / `GEMINI.md`, if the project uses them

## Overrideable categories

Projects may override or define:

- Tech stack and architecture overview
- Package manager and common commands
- Test, lint, typecheck, build commands
- Directory layout and naming conventions
- Domain-specific review criteria
- Documentation sync rules
- Preferred task granularity
- Code ownership boundaries
- Release or PR process
- Project-specific escalation triggers

## Not overrideable

Projects must not weaken:

- Evidence before completion
- Secret handling
- Destructive-action approval
- Scope discipline
- High-risk escalation
- Parallel write ownership
- No bypassing tests/types/security checks
- Short workflow command routing from the global andy harness, including commands such as `brainstorm issue #123`

Project `AGENTS.md` files may add local context, but they should not redefine `core/workflows/` as project-relative unless the project intentionally vendors andy under `./.andy/harness`.

## Override template

```markdown
# Project Overrides for <project>

## Project Overview

## Tech Stack

## Commands
| Purpose | Command |
|---|---|
| install | |
| test | |
| typecheck | |
| lint | |
| build | |

## Directory Map

## Coding Conventions

## Test Strategy

## Documentation Sync Rules

## Project-specific Escalation

## Known Risks / Anti-patterns
```
