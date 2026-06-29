# Setup Skill Discovery Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a runtime-neutral `/setup` workflow that inspects the current repository, searches GitHub agent skills with GitHub CLI, and installs selected skills only after user consent.

**Architecture:** Keep orchestration in `core/workflows/setup.md` and expose it through the existing generated adapter-command pipeline. `core/` remains runtime-neutral; Codex, Claude, Gemini, and Fugu consume generated adapter files from the shared catalog.

**Tech Stack:** Markdown workflow runbooks, JSON command catalog, Python command generator, Bash validation script.

---

### Task 1: Add the neutral setup workflow

**Files:**
- Create: `core/workflows/setup.md`

**Step 1: Define workflow goals and safety rules**

Write a runbook that treats the current working directory as the target repository, avoids secrets, and requires user approval before installation.

**Step 2: Define repository inventory**

List safe files to inspect: `AGENTS.md`, `README*`, package manifests, lockfiles, build/test configs, Docker/Terraform/workflow files, and docs folders.

**Step 3: Define GitHub CLI skill operations**

Use `gh skill search` for candidates, `gh skill preview` for details, and `gh skill install` only after user approval. Prefer project-local neutral installation via `.agents/skills` or an equivalent universal/project scope.

**Step 4: Define output format**

Require a summary of detected stack, recommended skills, install decisions, verification, and remaining risks.

### Task 2: Add setup to command routing and adapters

**Files:**
- Modify: `core/workflows/command-router.md`
- Modify: `adapters/commands/catalog.json`
- Generated: `adapters/codex/prompts/setup.md`
- Generated: `adapters/claude/commands/setup.md`
- Generated: `adapters/gemini/commands/setup.toml`

**Step 1: Update router grammar and routing table**

Add `setup [search hints]` and map it to `core/workflows/setup.md`.

**Step 2: Add setup command catalog entry**

Add a catalog object whose generated commands resolve the harness root, load the router and setup workflow, and pass `$ARGUMENTS` / `{{args}}`.

**Step 3: Regenerate adapters**

Run: `python3 scripts/generate-commands.py`

Expected: writes new setup files for Codex, Claude, and Gemini.

### Task 3: Update docs and Fugu config

**Files:**
- Modify: `AGENTS.md`
- Modify: `README.md`
- Modify: `adapters/README.md`
- Modify: `adapters/codex/README.md`
- Modify: `adapters/claude/README.md`
- Modify: `adapters/gemini/README.md`
- Modify: `adapters/fugu/README.md`
- Modify: `adapters/fugu/config.template.json`
- Modify: `core/policies/skill-loading-policy.md`
- Modify: `templates/project/AGENTS.md`

**Step 1: Document `/setup` alongside the other workflow commands**

Add setup to command examples and command lists.

**Step 2: Expose setup in Fugu config**

Add `setup: core/workflows/setup.md` to `commands`.

**Step 3: Mention setup skill phase**

Add setup to skill-loading policy phase defaults as project/domain skill discovery.

### Task 4: Update validation and run checks

**Files:**
- Modify: `scripts/validate-harness.sh`

**Step 1: Add setup required files**

Add setup workflow and generated adapter files to `required`.

**Step 2: Add setup adapter checks**

Include `setup` in command loops for Codex, Claude, and Gemini.

**Step 3: Run verification**

Run:

```bash
python3 scripts/generate-commands.py --check
./scripts/validate-harness.sh
```

Expected: both commands pass.
