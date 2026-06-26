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

if [[ ! -x "$ROOT/install.sh" ]]; then fail "install.sh is not executable"; fi
if [[ ! -x "$ROOT/uninstall.sh" ]]; then fail "uninstall.sh is not executable"; fi

if [[ $errors -gt 0 ]]; then
  echo "Validation failed with $errors error(s)."
  exit 1
fi

echo "andy harness validation passed."
