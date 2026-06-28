# Workflow: command-router

## Goal

Route short user commands such as `brainstorm issue #123` to the correct andy workflow without requiring the user to mention `AGENTS.md` or long harness paths.

## Inputs

- Raw user request
- Current working directory
- Resolved andy harness root
- Optional GitHub issue or proposal/task artifact

## Command grammar

```text
brainstorm [topic | issue #123 | owner/repo#123]
spec <change-name | proposal path | issue #123>
implement <change-name | tasks path>
review [change-name]
test [change-name]
compound [topic]
ship [topic | issue #123 | owner/repo#123]
```

Also accept natural Japanese around the command word when the intent is clear, for example `issue #123 を brainstorm`.

## Routing table

| Command | Load workflow | Primary input |
|---|---|---|
| `brainstorm` | `core/workflows/brainstorm.md` | topic or issue |
| `spec` | `core/workflows/spec.md` | proposal or change |
| `implement` | `core/workflows/implement.md` | approved tasks |
| `review` | `core/workflows/review.md` | current diff or change |
| `test` | `core/workflows/test.md` | current diff or change |
| `compound` | `core/workflows/compound.md` | completed change or learning |
| `ship` | `core/workflows/ship.md` | topic or issue |

## Issue input resolution

For `issue #123`:

1. Treat `#123` as an issue in the current GitHub repository.
2. Prefer `gh issue view 123 --json number,title,body,state,labels,assignees,comments,url`.
3. If the repository is not detected or `gh` cannot fetch the issue, ask for the issue text or the missing access step.

For `owner/repo#123`:

1. Treat `owner/repo` as explicit.
2. Prefer `gh issue view 123 --repo owner/repo --json number,title,body,state,labels,assignees,comments,url`.

Do not invent issue contents if fetch fails.

## Change name derivation

For issue-backed brainstorm, derive the default change name as:

```text
issue-<number>-<short-kebab-title>
```

Keep the slug short, lowercase, and filesystem-safe. If the issue title is unavailable, use `issue-<number>`.

## Target project rules

- The current working directory is the target project.
- Create and read OpenSpec artifacts under `./openspec/changes/<change-name>/` in the target project.
- Read harness instructions from the resolved andy harness root.
- Never write generated project artifacts into `~/.codex/harnesses/andy` or `~/.codex/active-harness` unless the target project is the andy harness repository itself.

## Approval gates

The router must not weaken workflow gates:

- `brainstorm` stops after proposal and asks for user approval before `spec`.
- `spec` stops after design/spec/tasks/traceability and asks for user approval before `implement`.
