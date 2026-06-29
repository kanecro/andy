# AGENTS.md -- andy Universal Agent Harness

This repository defines **andy**, an agent-neutral development harness intended to work well with Fugu, Codex, Claude, Gemini, and future coding agents.

`AGENTS.md` is the canonical entrypoint. Tool-specific files such as `CLAUDE.md` and `GEMINI.md` are thin shims that point back here.

## Core Philosophy

1. **Explore First**: Read existing code, specs, tests, and project conventions before changing behavior.
2. **Plan Before Execute**: For work with 3+ steps, decompose into tasks before editing.
3. **Minimal Change**: Do exactly what was requested. Avoid opportunistic refactors, extra features, and noisy comments.
4. **Spec-Aware**: When specs exist, tie implementation, review, and tests back to the spec.
5. **Evidence Before Claims**: Do not claim completion, success, or a fix without fresh verification evidence.
6. **Model-Agnostic**: Do not hardcode model names as the process. Define roles, capability profiles, artifacts, policies, and guardrails.
7. **Parallel With Ownership**: Parallel workers must have explicit write scopes and must not revert or overwrite each other's work.

## Rule Layers

andy uses two rule layers:

1. **Immutable Rules** — global invariants that every agent must preserve. See `core/policies/immutable-rules.md`.
2. **Project Overrides** — repository-specific conventions and commands. See `core/policies/project-overrides-policy.md`.

Precedence is defined in `core/policies/rule-precedence-policy.md`. In short: higher-level runtime/user instructions win, project overrides may specialize defaults, but project overrides must not weaken immutable rules.

## Standard Workflow

```text
brainstorm → spec → implement → review → test → compound
```

- Ask for user approval after `brainstorm` and `spec` before implementation.
- After approval, `implement` / `review` / `test` / `compound` may run autonomously within scope.
- Escalate security, database, production, destructive, or breaking-contract decisions.

## Short Workflow Commands

andy exposes two equivalent ways to start a workflow. The user never needs to
state a long harness path.

**Preferred (deterministic): slash commands.** After install, supported runtimes
expose one command per workflow in any repository:

```text
/brainstorm issue #123
/spec issue-123-add-notifications
/implement issue-123-add-notifications
/review
/test
/compound
/setup
/ship issue #123
```

Runtime command adapters:

| Runtime | Adapter files | Installed by |
|---|---|---|
| Codex / codex-fugu | `adapters/codex/prompts/*.md` | `./install.sh` |
| Claude Code | `adapters/claude/commands/*.md` | `./install.sh --with-claude` |
| Gemini CLI / Antigravity | `adapters/gemini/commands/*.toml` | `./install.sh --with-gemini` |

**Fallback: plain-message routing.** When the user's request starts with one of
these workflow words (without a slash), treat it as an andy workflow command and
do not ask the user to restate a long file path:

```text
brainstorm [topic | issue #123 | owner/repo#123]
spec <change-name | proposal path | issue #123>
implement <change-name | tasks path>
review [change-name]
test [change-name]
compound [topic]
setup [search hints]
ship [topic | issue #123 | owner/repo#123]
```

Command handling:

1. Resolve the andy harness root. Default installed candidates are `${CODEX_HOME:-$HOME/.codex}/active-harness`, then `${CODEX_HOME:-$HOME/.codex}/harnesses/andy`; the resolved directory must contain `AGENTS.md` and `core/workflows/`.
2. Load `core/workflows/command-router.md`, then load only the workflow runbook needed for the command.
3. Treat the current working directory as the target development repository. Write generated artifacts to that repository, never to the installed harness directory, unless the user explicitly asks to edit the harness.
4. For `setup`, inspect the target repository, search GitHub CLI agent skills, ask before installing, and prefer project-local neutral skills under `.agents/skills/` or an equivalent universal/project-scope target.
5. For `issue #123`, use the current repository's GitHub issue. For `owner/repo#123`, use that explicit GitHub repository. If available, inspect the issue with `gh issue view` and include title, body, labels, state, URL, and relevant comments as workflow input. If the issue cannot be fetched, ask the user for the issue text or permission/credentials needed to fetch it.
6. Preserve the approval gates: stop for user approval after `brainstorm` and after `spec` before implementation.

## Required Core Files

Load only what is relevant to the task.

| File | Purpose |
|---|---|
| `core/principles.md` | Durable principles |
| `core/policies/rule-precedence-policy.md` | Rule ordering and conflict resolution |
| `core/policies/immutable-rules.md` | Non-negotiable global invariants |
| `core/policies/project-overrides-policy.md` | What projects may customize |
| `core/policies/escalation-policy.md` | When to ask the user |
| `core/policies/context-isolation-policy.md` | Coordinator / worker separation |
| `core/policies/verification-policy.md` | Evidence-before-claims rules |
| `core/policies/skill-loading-policy.md` | Candidate broadly, load narrowly |
| `core/policies/harness-resolution-policy.md` | Find the installed harness from any repository |
| `core/workflows/command-router.md` | Map short commands to workflow runbooks |
| `core/workflows/*.md` | Workflow runbooks |
| `core/roles/*.md` | Worker role contracts |
| `core/artifact-schemas/*.md` | Output schemas |

## Role Selection Policy

Let the active runtime or orchestrator choose models. andy describes capability profiles instead.

- **coordinator**: planning, decomposition, handoff, escalation
- **codebase-analyzer**: retrieval, pattern extraction, impact analysis
- **researcher**: current/official source retrieval when needed
- **spec-writer**: requirement formalization and artifact writing
- **spec-validator**: adversarial ambiguity and gap detection
- **implementer**: scoped code editing, tests, minimal change, TDD
- **build-error-resolver**: root-cause debugging and minimal repair
- **reviewer**: read-only critique and risk detection
- **review-aggregator**: deduplication, prioritization, coverage matrix

## Guardrails

Use deterministic checks in `scripts/guardrails/` where possible instead of relying only on model attention.

- Avoid ad-hoc `.md` / `.txt` files in project roots.
- Warn on debug `console.log` in source files.
- Avoid foreground long-running server processes that block the session.
- Do not force push or run destructive git commands without explicit confirmation.
- Do not read or edit secrets, `.env` files, or private keys.

## Adapter Entrypoints

| Runtime / agent | Entrypoint |
|---|---|
| Agent-neutral / Codex-style | `AGENTS.md` |
| Claude-style | `CLAUDE.md` → imports `AGENTS.md` |
| Gemini-style | `GEMINI.md` → imports `AGENTS.md` |
| Fugu | `adapters/fugu/config.template.json` uses `AGENTS.md` |

## Completion Report Format

```markdown
## Summary
- [change summary]

## Changed Files
- `path`: [why it changed]

## Verification
- [command or inspection]: [result]

## Remaining Risks
- [if any]
```
