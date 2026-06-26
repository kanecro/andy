# andy Fugu Harness Implementation Plan

> **For Fugu:** Use andy's implement workflow task-by-task. This plan has already been executed for the initial scaffold.

**Goal:** Create `../andy` as a Fugu-first user-level harness with install/uninstall mechanisms.

**Architecture:** andy separates runtime-independent `core/` from `adapters/fugu/`. Install/uninstall use symlinks into `${FUGU_HOME:-~/.fugu}` so updates to the andy directory are reflected without copying.

**Tech Stack:** Markdown runbooks, Bash installer, Node.js guardrail scripts, JSON config template.

---

### Task 1: Scaffold directory

**Files:**
- Create: `README.md`
- Create: `AGENTS.md`
- Create: `CLAUDE.md`
- Create: `GEMINI.md`
- Create: `core/**`
- Create: `adapters/fugu/**`
- Create: `scripts/**`

**Steps:**
1. Create the andy root directory.
2. Add core principles, policies, workflows, roles, skills, schemas, guardrails.
3. Add Fugu adapter docs and config template.

### Task 2: Add install/uninstall

**Files:**
- Create: `install.sh`
- Create: `uninstall.sh`

**Steps:**
1. Install symlinks to `~/.fugu/harnesses/andy`, `~/.fugu/AGENTS.md` / `~/.fugu/CLAUDE.md` / `~/.fugu/GEMINI.md`, config template, and active harness.
2. Backup existing conflicting files after confirmation.
3. Uninstall only symlinks that point to andy.

### Task 3: Add validation and guardrails

**Files:**
- Create: `scripts/validate-harness.sh`
- Create: `scripts/guardrails/*.js`

**Steps:**
1. Validate required files exist.
2. Ensure core does not contain Claude Code runtime terms.
3. Validate JSON config.
4. Provide generic command/write/console/git guardrail scripts.

### Task 4: Universal agent entrypoints

**Files:**
- Rename: legacy entrypoint → `AGENTS.md`
- Create: `CLAUDE.md`
- Create: `GEMINI.md`
- Create: `adapters/codex/README.md`
- Create: `adapters/claude/README.md`
- Create: `adapters/gemini/README.md`

**Steps:**
1. Make `AGENTS.md` the canonical entrypoint.
2. Keep runtime-specific files as thin shims.
3. Update install/uninstall/validate/config references.
