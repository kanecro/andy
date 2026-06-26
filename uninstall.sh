#!/usr/bin/env bash
set -euo pipefail

FORCE=false
REMOVE_CODEX=false
REMOVE_CLAUDE=false
REMOVE_GEMINI=false
FUGU_HOME="${FUGU_HOME:-$HOME/.fugu}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
GEMINI_HOME="${GEMINI_HOME:-$HOME/.gemini}"

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Uninstall andy symlinks from \${FUGU_HOME:-~/.fugu}.
Optional global shims are removed only when requested.

Options:
  -y, --yes          Skip confirmation prompts
  --target DIR       Override FUGU_HOME for this uninstall
  --with-codex       Also remove ~/.codex/AGENTS.md if it is an andy symlink
  --with-claude      Also remove ~/.claude/CLAUDE.md if it is an andy symlink
  --with-gemini      Also remove ~/.gemini/GEMINI.md if it is an andy symlink
  --all-agents       Enable all optional global shim removals
  -h, --help         Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes) FORCE=true; shift ;;
    --target) FUGU_HOME="$2"; shift 2 ;;
    --with-codex) REMOVE_CODEX=true; shift ;;
    --with-claude) REMOVE_CLAUDE=true; shift ;;
    --with-gemini) REMOVE_GEMINI=true; shift ;;
    --all-agents) REMOVE_CODEX=true; REMOVE_CLAUDE=true; REMOVE_GEMINI=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

confirm() {
  $FORCE && return 0
  read -r -p "$1 [y/N] " ans
  [[ "$ans" =~ ^[Yy]$ ]]
}

ok() { printf '\033[32m[ OK ]\033[0m %-34s %s\n' "$1" "$2"; }
warn() { printf '\033[33m[WARN]\033[0m %-34s %s\n' "$1" "$2"; }
info() { printf '\033[34m[INFO]\033[0m %-34s %s\n' "$1" "$2"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ANDY_ROOT="$SCRIPT_DIR"
TARGET_DIR="$FUGU_HOME/harnesses/andy"

if [[ ! -d "$FUGU_HOME" ]]; then
  info "FUGU_HOME" "not found; checking optional globals only"
else
  if ! confirm "Remove andy symlinks from $FUGU_HOME?"; then
    echo "Cancelled."
    exit 0
  fi
fi

remove_link_if_matches() {
  local path="$1" expected="$2" label="$3"
  if [[ -L "$path" ]]; then
    local current
    current="$(readlink "$path")"
    if [[ "$current" == "$expected" || "$current" == "$TARGET_DIR"* || "$current" == "$ANDY_ROOT"* ]]; then
      rm "$path"
      ok "$label" "removed"
    else
      warn "$label" "not andy symlink: $current"
    fi
  elif [[ -e "$path" ]]; then
    warn "$label" "not symlink; kept"
  fi
}

remove_link_if_matches "$FUGU_HOME/AGENTS.md" "$TARGET_DIR/AGENTS.md" "Fugu AGENTS.md"
remove_link_if_matches "$FUGU_HOME/CLAUDE.md" "$TARGET_DIR/CLAUDE.md" "Fugu CLAUDE.md"
remove_link_if_matches "$FUGU_HOME/GEMINI.md" "$TARGET_DIR/GEMINI.md" "Fugu GEMINI.md"
remove_link_if_matches "$FUGU_HOME/andy.config.template.json" "$TARGET_DIR/adapters/fugu/config.template.json" "config template"
remove_link_if_matches "$FUGU_HOME/active-harness" "$TARGET_DIR" "active-harness"
remove_link_if_matches "$TARGET_DIR" "$ANDY_ROOT" "harnesses/andy"
LEGACY_ENTRYPOINT="andy"".md"
remove_link_if_matches "$FUGU_HOME/$LEGACY_ENTRYPOINT" "$TARGET_DIR/$LEGACY_ENTRYPOINT" "legacy entrypoint"

if $REMOVE_CODEX; then
  remove_link_if_matches "$CODEX_HOME/AGENTS.md" "$TARGET_DIR/AGENTS.md" "Codex AGENTS.md"
fi
if $REMOVE_CLAUDE; then
  remove_link_if_matches "$CLAUDE_HOME/CLAUDE.md" "$TARGET_DIR/CLAUDE.md" "Claude CLAUDE.md"
fi
if $REMOVE_GEMINI; then
  remove_link_if_matches "$GEMINI_HOME/GEMINI.md" "$TARGET_DIR/GEMINI.md" "Gemini GEMINI.md"
fi

warn "config.json" "kept if present; remove manually if unwanted: $FUGU_HOME/config.json"
ok "complete" "andy symlink uninstall complete"
