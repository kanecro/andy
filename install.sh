#!/usr/bin/env bash
set -euo pipefail

FORCE=false
SET_ACTIVE=true
INSTALL_CLAUDE=false
INSTALL_GEMINI=false
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
GEMINI_HOME="${GEMINI_HOME:-$HOME/.gemini}"

usage() {
  cat <<EOF_USAGE
Usage: $(basename "$0") [OPTIONS]

Install andy harness symlinks into \${CODEX_HOME:-~/.codex}.
Codex and codex-fugu both load the Codex-compatible entrypoint at
\${CODEX_HOME:-~/.codex}/AGENTS.md, so this is the only default install target.
Claude and Gemini global shims are opt-in.

Options:
  -y, --yes          Skip confirmation prompts
  --no-active        Do not create ~/.codex/active-harness
  --target DIR       Override CODEX_HOME for this install
  --with-claude      Also link ~/.claude/CLAUDE.md
  --with-gemini      Also link ~/.gemini/GEMINI.md
  --all-agents       Enable Claude and Gemini shims too
  -h, --help         Show this help
EOF_USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes) FORCE=true; shift ;;
    --no-active) SET_ACTIVE=false; shift ;;
    --target) CODEX_HOME="$2"; shift 2 ;;
    --with-claude) INSTALL_CLAUDE=true; shift ;;
    --with-gemini) INSTALL_GEMINI=true; shift ;;
    --all-agents) INSTALL_CLAUDE=true; INSTALL_GEMINI=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

confirm() {
  $FORCE && return 0
  read -r -p "$1 [y/N] " ans
  [[ "$ans" =~ ^[Yy]$ ]]
}

info() { printf '\033[34m[INFO]\033[0m %-34s %s\n' "$1" "$2"; }
ok() { printf '\033[32m[ OK ]\033[0m %-34s %s\n' "$1" "$2"; }
warn() { printf '\033[33m[WARN]\033[0m %-34s %s\n' "$1" "$2"; }
fail() { printf '\033[31m[FAIL]\033[0m %-34s %s\n' "$1" "$2"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ANDY_ROOT="$SCRIPT_DIR"
TARGET_DIR="$CODEX_HOME/harnesses/andy"
BACKUP_DIR="$CODEX_HOME/.andy-backups/andy-$(date +%Y%m%d-%H%M%S)"

[[ -f "$ANDY_ROOT/AGENTS.md" ]] || { fail "AGENTS.md" "not found; run from andy root"; exit 1; }

mkdir -p "$CODEX_HOME/harnesses" "$CODEX_HOME/.andy-backups"

backup_name_for() {
  local path="$1"
  path="${path#/}"
  printf '%s' "${path//\//__}"
}

link_path() {
  local src="$1" dest="$2" label="$3" backup_base="${4:-$BACKUP_DIR}"
  mkdir -p "$(dirname "$dest")"
  if [[ -L "$dest" ]]; then
    local current
    current="$(readlink "$dest")"
    if [[ "$current" == "$src" ]]; then ok "$label" "already linked"; return 0; fi
    warn "$label" "symlink points to $current"
    if confirm "Replace symlink $dest?"; then ln -sfn "$src" "$dest"; ok "$label" "updated"; else warn "$label" "skipped"; fi
    return 0
  fi
  if [[ -e "$dest" ]]; then
    warn "$label" "existing file/directory found"
    if confirm "Backup and replace $dest?"; then
      mkdir -p "$backup_base"
      mv "$dest" "$backup_base/$(backup_name_for "$dest")"
      ln -sfn "$src" "$dest"
      ok "$label" "backed up and linked"
    else
      warn "$label" "skipped"
    fi
    return 0
  fi
  ln -sfn "$src" "$dest"
  ok "$label" "linked"
}

info "andy root" "$ANDY_ROOT"
info "CODEX_HOME" "$CODEX_HOME"

link_path "$ANDY_ROOT" "$TARGET_DIR" "harnesses/andy"
link_path "$TARGET_DIR/AGENTS.md" "$CODEX_HOME/AGENTS.md" "Codex AGENTS.md"
link_path "$TARGET_DIR/adapters/fugu/config.template.json" "$CODEX_HOME/andy.config.template.json" "config template"

if $SET_ACTIVE; then
  link_path "$TARGET_DIR" "$CODEX_HOME/active-harness" "active-harness"
fi

if [[ ! -f "$CODEX_HOME/andy.config.json" ]]; then
  cp "$ANDY_ROOT/adapters/fugu/config.template.json" "$CODEX_HOME/andy.config.json"
  ok "andy.config.json" "created from template"
else
  warn "andy.config.json" "already exists; not overwritten"
fi

if $INSTALL_CLAUDE; then
  link_path "$TARGET_DIR/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md" "Claude CLAUDE.md"
fi
if $INSTALL_GEMINI; then
  link_path "$TARGET_DIR/GEMINI.md" "$GEMINI_HOME/GEMINI.md" "Gemini GEMINI.md"
fi

"$ANDY_ROOT/scripts/validate-harness.sh" "$ANDY_ROOT"

echo
ok "complete" "andy installed into $CODEX_HOME"
