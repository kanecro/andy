#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)}"
errors=0

fail() { echo "[FAIL] $*"; errors=$((errors + 1)); }
ok() { echo "[ OK ] $*"; }

required=(
  "AGENTS.md"
  "CLAUDE.md"
  "GEMINI.md"
  "README.md"
  "install.sh"
  "uninstall.sh"
  "core/principles.md"
  "templates/project/.andy/overrides.md"
  "templates/project/AGENTS.md"
  "core/policies/project-overrides-policy.md"
  "core/policies/immutable-rules.md"
  "core/policies/rule-precedence-policy.md"
  "core/policies/harness-resolution-policy.md"
  "core/workflows/command-router.md"
  "core/workflows/brainstorm.md"
  "core/workflows/spec.md"
  "core/workflows/implement.md"
  "core/workflows/review.md"
  "core/workflows/test.md"
  "core/workflows/compound.md"
  "core/workflows/setup.md"
  "core/workflows/ship.md"
  "adapters/commands/catalog.json"
  "adapters/codex/prompts/brainstorm.md"
  "adapters/codex/prompts/spec.md"
  "adapters/codex/prompts/implement.md"
  "adapters/codex/prompts/review.md"
  "adapters/codex/prompts/test.md"
  "adapters/codex/prompts/compound.md"
  "adapters/codex/prompts/setup.md"
  "adapters/codex/prompts/ship.md"
  "adapters/codex/prompts/README.md"
  "adapters/claude/commands/brainstorm.md"
  "adapters/claude/commands/spec.md"
  "adapters/claude/commands/implement.md"
  "adapters/claude/commands/review.md"
  "adapters/claude/commands/test.md"
  "adapters/claude/commands/compound.md"
  "adapters/claude/commands/setup.md"
  "adapters/claude/commands/ship.md"
  "adapters/gemini/commands/brainstorm.toml"
  "adapters/gemini/commands/spec.toml"
  "adapters/gemini/commands/implement.toml"
  "adapters/gemini/commands/review.toml"
  "adapters/gemini/commands/test.toml"
  "adapters/gemini/commands/compound.toml"
  "adapters/gemini/commands/setup.toml"
  "adapters/gemini/commands/ship.toml"
  "adapters/README.md"
  "adapters/fugu/README.md"
  "adapters/fugu/config.template.json"
  "adapters/codex/README.md"
  "adapters/claude/README.md"
  "adapters/gemini/README.md"
  "scripts/guardrails/check-command.js"
  "scripts/guardrails/check-write-path.js"
  "scripts/guardrails/check-console-log.js"
  "scripts/guardrails/check-git-push.js"
  "scripts/generate-commands.py"
)

for f in "${required[@]}"; do
  if [[ -f "$ROOT/$f" ]]; then ok "$f"; else fail "missing: $f"; fi
done

LEGACY_ENTRYPOINT="andy"".md"
if [[ -e "$ROOT/$LEGACY_ENTRYPOINT" ]]; then
  fail "legacy entrypoint still exists"
else
  ok "legacy entrypoint absent"
fi

if grep -RIn --exclude-dir=.git -E 'Task\(|TeamCreate|TeamDelete|SendMessage|AskUserQuestion|~/.claude|model: *(opus|sonnet)|permissionMode:|bypassPermissions' "$ROOT/core" >/tmp/andy-core-legacy-grep.$$ 2>/dev/null; then
  cat /tmp/andy-core-legacy-grep.$$
  rm -f /tmp/andy-core-legacy-grep.$$
  fail "core contains checked runtime-specific orchestration terms"
else
  rm -f /tmp/andy-core-legacy-grep.$$
  ok "core is free of checked runtime-specific orchestration terms"
fi

if grep -RIn --exclude-dir=.git 'andy\.md' "$ROOT" >/tmp/andy-md-grep.$$ 2>/dev/null; then
  cat /tmp/andy-md-grep.$$
  rm -f /tmp/andy-md-grep.$$
  fail "repository still references legacy entrypoint name"
else
  rm -f /tmp/andy-md-grep.$$
  ok "no legacy entrypoint references"
fi

python3 -m json.tool "$ROOT/adapters/fugu/config.template.json" >/dev/null && ok "Fugu config template is valid JSON" || fail "invalid Fugu config JSON"

entrypoint="$(ROOT_FOR_PY="$ROOT" python3 - <<'ENTRYPOINT_PY'
import json, os
from pathlib import Path
p = Path(os.environ['ROOT_FOR_PY']) / 'adapters/fugu/config.template.json'
print(json.loads(p.read_text()).get('entrypoint'))
ENTRYPOINT_PY
)"
if [[ "$entrypoint" == "AGENTS.md" ]]; then ok "Fugu entrypoint is AGENTS.md"; else fail "Fugu entrypoint is $entrypoint"; fi

codex_entrypoint="$(ROOT_FOR_PY="$ROOT" python3 - <<'CODEX_ENTRYPOINT_PY'
import json, os
from pathlib import Path
p = Path(os.environ['ROOT_FOR_PY']) / 'adapters/fugu/config.template.json'
print(json.loads(p.read_text()).get('installation', {}).get('defaultCodexEntrypoint'))
CODEX_ENTRYPOINT_PY
)"
if [[ "$codex_entrypoint" == "~/.codex/AGENTS.md" ]]; then ok "Codex default entrypoint is ~/.codex/AGENTS.md"; else fail "Codex default entrypoint is $codex_entrypoint"; fi

codex_home="$(ROOT_FOR_PY="$ROOT" python3 - <<'CODEX_HOME_PY'
import json, os
from pathlib import Path
p = Path(os.environ['ROOT_FOR_PY']) / 'adapters/fugu/config.template.json'
print(json.loads(p.read_text()).get('installation', {}).get('defaultCodexHome'))
CODEX_HOME_PY
)"
if [[ "$codex_home" == "~/.codex" ]]; then ok "default harness home is ~/.codex"; else fail "default harness home is $codex_home"; fi

harness_symlink="$(ROOT_FOR_PY="$ROOT" python3 - <<'HARNESS_SYMLINK_PY'
import json, os
from pathlib import Path
p = Path(os.environ['ROOT_FOR_PY']) / 'adapters/fugu/config.template.json'
print(json.loads(p.read_text()).get('installation', {}).get('harnessSymlink'))
HARNESS_SYMLINK_PY
)"
if [[ "$harness_symlink" == "~/.codex/harnesses/andy" ]]; then ok "harness symlink is under ~/.codex"; else fail "harness symlink is $harness_symlink"; fi

if grep -q 'brainstorm issue #123' "$ROOT/AGENTS.md" && grep -q 'command-router.md' "$ROOT/AGENTS.md"; then
  ok "AGENTS.md documents short workflow commands"
else
  fail "AGENTS.md missing short workflow command routing"
fi

if grep -q 'active-harness' "$ROOT/core/policies/harness-resolution-policy.md"; then
  ok "harness resolution policy documents active-harness"
else
  fail "harness resolution policy missing active-harness"
fi

if python3 "$ROOT/scripts/generate-commands.py" --check >/tmp/andy-generate-commands-check.$$ 2>&1; then
  rm -f /tmp/andy-generate-commands-check.$$
  ok "generated runtime commands are up to date"
else
  cat /tmp/andy-generate-commands-check.$$
  rm -f /tmp/andy-generate-commands-check.$$
  fail "generated runtime commands are out of date"
fi

# Codex prompts: markdown + $ARGUMENTS, harness-aware.
for cmd in brainstorm spec implement review test compound setup ship; do
  pf="$ROOT/adapters/codex/prompts/$cmd.md"
  if [[ -f "$pf" ]] && grep -q 'ARGUMENTS' "$pf" && grep -q 'active-harness' "$pf"; then
    ok "codex prompt /$cmd is harness-aware and arg-driven"
  else
    fail "codex prompt /$cmd missing \$ARGUMENTS or harness resolution"
  fi
done

# Claude commands: markdown + $ARGUMENTS, harness-aware.
for cmd in brainstorm spec implement review test compound setup ship; do
  pf="$ROOT/adapters/claude/commands/$cmd.md"
  if [[ -f "$pf" ]] && grep -q 'ARGUMENTS' "$pf" && grep -q 'active-harness' "$pf"; then
    ok "claude command /$cmd is harness-aware and arg-driven"
  else
    fail "claude command /$cmd missing \$ARGUMENTS or harness resolution"
  fi
done

# Gemini commands (also Antigravity): TOML + {{args}}, harness-aware.
for cmd in brainstorm spec implement review test compound setup ship; do
  pf="$ROOT/adapters/gemini/commands/$cmd.toml"
  if [[ -f "$pf" ]] && grep -q '{{args}}' "$pf" && grep -q 'description' "$pf" && grep -q 'active-harness' "$pf"; then
    ok "gemini command /$cmd is harness-aware and arg-driven"
  else
    fail "gemini command /$cmd missing {{args}} or harness resolution"
  fi
done

command_router="$(ROOT_FOR_PY="$ROOT" python3 - <<'COMMAND_ROUTER_PY'
import json, os
from pathlib import Path
p = Path(os.environ['ROOT_FOR_PY']) / 'adapters/fugu/config.template.json'
print(json.loads(p.read_text()).get('core', {}).get('commandRouter'))
COMMAND_ROUTER_PY
)"
if [[ "$command_router" == "core/workflows/command-router.md" ]]; then ok "Fugu config exposes command router"; else fail "Fugu command router is $command_router"; fi

command_adapters="$(ROOT_FOR_PY="$ROOT" python3 - <<'COMMAND_ADAPTERS_PY'
import json, os
from pathlib import Path
p = Path(os.environ['ROOT_FOR_PY']) / 'adapters/fugu/config.template.json'
cfg = json.loads(p.read_text()).get('installation', {}).get('commandAdapters', {})
print('|'.join([cfg.get('codex', ''), cfg.get('claude', ''), cfg.get('gemini', '')]))
COMMAND_ADAPTERS_PY
)"
if [[ "$command_adapters" == "adapters/codex/prompts|adapters/claude/commands|adapters/gemini/commands" ]]; then
  ok "Fugu config exposes runtime command adapters"
else
  fail "Fugu command adapters are $command_adapters"
fi

command_generation="$(ROOT_FOR_PY="$ROOT" python3 - <<'COMMAND_GENERATION_PY'
import json, os
from pathlib import Path
p = Path(os.environ['ROOT_FOR_PY']) / 'adapters/fugu/config.template.json'
cfg = json.loads(p.read_text()).get('installation', {})
print('|'.join([cfg.get('commandCatalog', ''), cfg.get('commandGenerator', '')]))
COMMAND_GENERATION_PY
)"
if [[ "$command_generation" == "adapters/commands/catalog.json|scripts/generate-commands.py" ]]; then
  ok "Fugu config exposes command catalog and generator"
else
  fail "Fugu command generation config is $command_generation"
fi

legacy_env="FUGU""_HOME"
legacy_config_key="default""FuguHome"
legacy_home_regex="~/[.]fugu"
if grep -RIn -E "${legacy_env}|${legacy_config_key}|${legacy_home_regex}" "$ROOT/install.sh" "$ROOT/uninstall.sh" "$ROOT/README.md" "$ROOT/adapters/fugu/README.md" "$ROOT/adapters/fugu/config.template.json" >/tmp/andy-fugu-home-grep.$$ 2>/dev/null; then
  cat /tmp/andy-fugu-home-grep.$$
  rm -f /tmp/andy-fugu-home-grep.$$
  fail "active install docs still reference legacy Fugu home"
else
  rm -f /tmp/andy-fugu-home-grep.$$
  ok "active install docs avoid legacy Fugu home"
fi

if [[ ! -x "$ROOT/install.sh" ]]; then fail "install.sh is not executable"; fi
if [[ ! -x "$ROOT/uninstall.sh" ]]; then fail "uninstall.sh is not executable"; fi

if [[ $errors -gt 0 ]]; then
  echo "Validation failed with $errors error(s)."
  exit 1
fi

echo "andy harness validation passed."
