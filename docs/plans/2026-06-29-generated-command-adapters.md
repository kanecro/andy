# Generated Command Adapters Implementation Plan

> **For Fugu:** Use andy's implement workflow task-by-task. This plan implements generated runtime command adapters from a single catalog.

**Goal:** Prevent Codex/Claude/Gemini command drift by generating all runtime workflow commands from one source of truth.

**Architecture:** Add `adapters/commands/catalog.json` as the canonical workflow command catalog and `scripts/generate-commands.py` as the generator/checker. Generated files remain under runtime adapters (`adapters/codex/prompts`, `adapters/claude/commands`, `adapters/gemini/commands`) so install/uninstall behavior stays unchanged.

**Tech Stack:** Python standard library (`json`, `argparse`, `tomllib` optional in tests), Bash validation, Markdown/TOML generated command files.

---

### Task 1: Catalog and generator

**Files:**
- Create: `adapters/commands/catalog.json`
- Create: `scripts/generate-commands.py`

**Steps:**
1. Extract the seven workflow command definitions into JSON.
2. Write generator functions for Codex Markdown, Claude Markdown, and Gemini TOML.
3. Add `--check` mode that fails when generated files differ.

### Task 2: Generated command files

**Files:**
- Modify: `adapters/codex/prompts/*.md`
- Modify: `adapters/claude/commands/*.md`
- Modify: `adapters/gemini/commands/*.toml`

**Steps:**
1. Run the generator to rewrite command files with generated headers.
2. Ensure all generated files still resolve the harness root and pass arguments.

### Task 3: Validation and docs

**Files:**
- Modify: `scripts/validate-harness.sh`
- Modify: `README.md`
- Modify: `adapters/README.md`
- Modify: runtime adapter READMEs as needed

**Steps:**
1. Add catalog/generator to required files.
2. Add `python3 scripts/generate-commands.py --check` to validation.
3. Document that adapter command files are generated.

### Task 4: Verify

**Commands:**
- `python3 scripts/generate-commands.py --check`
- `./scripts/validate-harness.sh`
- `bash -n install.sh uninstall.sh scripts/validate-harness.sh`
- Throwaway `install.sh -y --all-agents` and `uninstall.sh -y --all-agents`.
