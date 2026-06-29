# Workflow: setup

## Goal

Inspect the current repository, find relevant agent skills, and install only the user-approved skills into the target repository in an agent-neutral way.

## Inputs

- Short command input such as `setup` or `setup <search hints>`
- Current working directory as the target development repository
- Existing project instructions, manifests, dependency files, docs, and test/build configuration
- GitHub CLI `gh skill` results, when available

## Outputs

- Installed project skills under `.agents/skills/` or the closest GitHub CLI universal/project-scope equivalent
- A setup report in the assistant response listing detected project traits, recommendations, user decisions, commands run, and verification evidence

## Preconditions

1. Treat the current working directory as the target repository.
2. Do not write to the installed andy harness unless the target repository is the andy harness repository itself.
3. Do not read secrets, `.env` files, private keys, credential stores, or hidden runtime state unrelated to setup.
4. Prefer GitHub CLI's built-in skill commands. If `gh skill` is unavailable, tell the user GitHub CLI with `gh skill` support is required, or ask whether to proceed with manual skill discovery.
5. Because `gh skill` searches remote sources and `gh skill install` writes files, ask for tool/network permission when the active runtime requires it.

## Repository inventory

Read narrowly and summarize only what is useful for skill matching:

1. Project instructions: `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.agents/**` indexes, if present.
2. Overview docs: `README*`, `docs/`, `openspec/`, `.github/ISSUE_TEMPLATE/`, excluding secrets.
3. Language/package manifests and lockfiles: `package.json`, `pnpm-lock.yaml`, `yarn.lock`, `package-lock.json`, `pyproject.toml`, `requirements*.txt`, `Pipfile`, `poetry.lock`, `Cargo.toml`, `go.mod`, `pom.xml`, `build.gradle*`, `Gemfile`, `composer.json`, and comparable ecosystem files.
4. Tooling/config files: test, lint, typecheck, formatting, Docker, Compose, Terraform, CI workflow, and deployment configuration files.
5. Source tree shape: top-level directories and representative filenames. Avoid exhaustive reads unless needed.

## Candidate search

1. Derive 3-8 search queries from the inventory. Include framework, language, test runner, infrastructure, and domain terms when they are strong signals.
2. If the command input includes search hints, include them as high-priority queries.
3. Use `gh skill search` for each query. Prefer concise output first; broaden only if results are sparse.
4. Use `gh skill preview` for promising candidates before recommending installation.
5. Favor skills that are:
   - directly relevant to the detected repository stack,
   - actively maintained or from a trusted source,
   - narrow enough to improve agent behavior without overloading context,
   - compatible with project-scope or universal installation.
6. Do not recommend installing generic or duplicate skills unless they fill a clear gap.

## Recommendation and approval gate

Before installing anything, stop and ask for user approval with a compact recommendation table:

| Skill | Why it fits | Install target | Risk / note |
|---|---|---|---|

The approval prompt must make clear that the user may approve all, some, or none of the recommendations.

## Installation

After approval:

1. Prefer an agent-neutral project-local target:
   - Install with the full `gh skill` signature `gh skill install <owner/repo> <skill-name> --dir .agents/skills`, using the `repo` and `skillName` returned by `gh skill search`. The repository argument is required.
   - If `--dir` is unavailable, use the closest GitHub CLI project/universal target, such as `gh skill install <owner/repo> <skill-name> --scope project --agent universal` (at project scope several agents share `.agents/skills`), and confirm the destination before proceeding.
   - To pin a version, append `@VERSION` to the skill name or use `--pin`.
2. Avoid user-global installs unless the user explicitly requests them.
3. Do not overwrite existing project skills without explicit user approval.
4. If a skill's installer asks interactive questions, preserve the user's choices; do not invent preferences.
5. After installation, inspect only non-secret installed metadata and summarize what changed.

## Verification

1. Run `gh skill list --dir .agents/skills` when available, or the equivalent project-scope list command.
2. Inspect `.agents/skills/` to confirm expected skill directories/files exist.
3. If the project has a harness validation command, run it when setup changed harness-facing files.
4. Report exact commands and outcomes. Do not claim a skill was installed unless verified.

## Fallback behavior

If GitHub CLI skill commands cannot run:

1. Report the missing command or permission failure.
2. Provide the repository inventory and suggested search queries.
3. Ask the user whether to install/update GitHub CLI, authenticate, grant network access, or continue manually.

## Completion report

Use the standard andy completion shape:

```markdown
## Summary
- [detected stack and setup outcome]

## Changed Files
- `.agents/skills/...`: [installed skill, if any]

## Verification
- [command or inspection]: [result]

## Remaining Risks
- [preview CLI behavior, no matching skill found, or skipped install]
```

## Common rules

- Follow `core/policies/escalation-policy.md`.
- Follow `core/policies/verification-policy.md` before claiming completion.
- Keep changes minimal and scoped.
- Write artifacts to the project, not to root ad-hoc notes, unless requested.
