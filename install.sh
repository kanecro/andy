#!/usr/bin/env bash
set -euo pipefail

FORCE=false
SET_ACTIVE=true
INSTALL_CODEX=false
INSTALL_CLAUDE=false
INSTALL_GEMINI=false
FUGU_HOME="${FUGU_HOME:-$HOME/.fugu}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
GEMINI_HOME="${GEMINI_HOME:-$HOME/.gemini}"

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Install andy harness symlinks.
Default install target is \${FUGU_HOME:-~/.fugu}; other agent homes are opt-in.

Options:
  -y, --yes          Skip confirmation prompts
  --no-active        Do not update ~/.fugu/active-harness
  --target DIR       Override FUGU_HOME for this install
  --with-codex       Also link ~/.codex/AGENTS.md
  --with-claude      Also link ~/.claude/CLAUDE.md
  --with-gemini      Also link ~/.gemini/GEMINI.md
  --all-agents       Enable all optional global shims
  -h, --help         Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes) FORCE=true; shift ;;
    --no-active) SET_ACTIVE=false; shift ;;
    --target) FUGU_HOME="$2"; shift 2 ;;
    --with-codex) INSTALL_CODEX=true; shift ;;
    --with-claude) INSTALL_CLAUDE=true; shift ;;
    --with-gemini) INSTALL_GEMINI=true; shift ;;
    --all-agents) INSTALL_CODEX=true; INSTALL_CLAUDE=true; INSTALL_GEMINI=true; shift ;;
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
TARGET_DIR="$FUGU_HOME/harnesses/andy"
BACKUP_DIR="$FUGU_HOME/backups/andy-$(date +%Y%m%d-%H%M%S)"

[[ -f "$ANDY_ROOT/AGENTS.md" ]] || { fail "AGENTS.md" "not found; run from andy root"; exit 1; }

mkdir -p "$FUGU_HOME/harnesses" "$FUGU_HOME/backups"

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
      mkdir -p "$backup_base/$(dirname "${dest#$HOME/}")"
      mv "$dest" "$backup_base/${dest#$HOME/}"
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
info "FUGU_HOME" "$FUGU_HOME"

link_path "$ANDY_ROOT" "$TARGET_DIR" "harnesses/andy"
link_path "$TARGET_DIR/AGENTS.md" "$FUGU_HOME/AGENTS.md" "Fugu AGENTS.md"
link_path "$TARGET_DIR/CLAUDE.md" "$FUGU_HOME/CLAUDE.md" "Fugu CLAUDE.md"
link_path "$TARGET_DIR/GEMINI.md" "$FUGU_HOME/GEMINI.md" "Fugu GEMINI.md"
link_path "$TARGET_DIR/adapters/fugu/config.template.json" "$FUGU_HOME/andy.config.template.json" "config template"

if $SET_ACTIVE; then
  link_path "$TARGET_DIR" "$FUGU_HOME/active-harness" "active-harness"
fi

if [[ ! -f "$FUGU_HOME/config.json" ]]; then
  cp "$ANDY_ROOT/adapters/fugu/config.template.json" "$FUGU_HOME/config.json"
  ok "config.json" "created from template"
else
  warn "config.json" "already exists; not overwritten"
fi

if $INSTALL_CODEX; then
  link_path "$TARGET_DIR/AGENTS.md" "$CODEX_HOME/AGENTS.md" "Codex AGENTS.md"
fi
if $INSTALL_CLAUDE; then
  link_path "$TARGET_DIR/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md" "Claude CLAUDE.md"
fi
if $INSTALL_GEMINI; then
  link_path "$TARGET_DIR/GEMINI.md" "$GEMINI_HOME/GEMINI.md" "Gemini GEMINI.md"
fi

"$ANDY_ROOT/scripts/validate-harness.sh" "$ANDY_ROOT"

echo
ok "complete" "andy installed into $FUGU_HOME"
