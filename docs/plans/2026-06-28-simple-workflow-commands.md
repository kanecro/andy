# Simple Workflow Commands Implementation Plan

> **For Fugu:** Use andy's implement workflow task-by-task. This plan documents the root fix for natural workflow commands such as `brainstorm issue #123`.

**Goal:** Make andy's harness workflows reliably usable from any development repository with short codex-fugu prompts like `brainstorm issue #xx`.

**Architecture:** Add a runtime-neutral command router to the global `AGENTS.md` and support it with a harness-root resolution policy plus workflow-specific input rules. The harness files remain under `~/.codex/active-harness`, while all generated artifacts are written to the current target project.

**Tech Stack:** Markdown harness instructions, Bash validation, existing andy install symlinks, optional GitHub CLI (`gh`) for issue lookup.

---

### Task 1: Add command routing to canonical instructions

**Files:**
- Modify: `AGENTS.md`
- Create: `core/workflows/command-router.md`
- Create: `core/policies/harness-resolution-policy.md`

**Steps:**
1. Define short workflow command grammar: `brainstorm`, `spec`, `implement`, `review`, `test`, `compound`, `ship`.
2. Define `issue #123` and `owner/repo#123` source resolution.
3. Define harness root lookup using `~/.codex/active-harness` and fallback paths.
4. Define target project as the current working directory, never the harness install directory.

### Task 2: Teach workflows how to consume issue inputs

**Files:**
- Modify: `core/workflows/brainstorm.md`
- Modify: `core/workflows/spec.md`
- Modify: `core/workflows/ship.md`

**Steps:**
1. Add issue inputs to brainstorm.
2. Add change-name derivation from issue title/number.
3. Add clear artifact locations under `./openspec/changes/<change-name>/`.
4. Keep approval gates after brainstorm and spec.

### Task 3: Update docs and adapters

**Files:**
- Modify: `README.md`
- Modify: `adapters/fugu/README.md`
- Modify: `adapters/fugu/workflow-map.md`
- Modify: `adapters/fugu/config.template.json`
- Modify: `templates/project/AGENTS.md`

**Steps:**
1. Replace cumbersome path-based examples with short commands.
2. Document installed harness paths only as implementation detail.
3. Document optional `gh issue view` behavior.
4. Ensure project templates do not override short command routing.

### Task 4: Validate

**Files:**
- Modify: `scripts/validate-harness.sh`

**Steps:**
1. Add required new files to validation.
2. Add checks that AGENTS documents short commands and active-harness path.
3. Run `./scripts/validate-harness.sh`.
4. Inspect `git diff` and report verification evidence.
