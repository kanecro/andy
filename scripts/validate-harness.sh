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
  "core/workflows/brainstorm.md"
  "core/workflows/spec.md"
  "core/workflows/implement.md"
  "core/workflows/review.md"
  "core/workflows/test.md"
  "core/workflows/compound.md"
  "core/workflows/ship.md"
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
