#!/usr/bin/env bash
set -euo pipefail

FORCE=false
REMOVE_CLAUDE=false
REMOVE_GEMINI=false
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
GEMINI_HOME="${GEMINI_HOME:-$HOME/.gemini}"

usage() {
  cat <<EOF_USAGE
Usage: $(basename "$0") [OPTIONS]

Uninstall andy symlinks from \${CODEX_HOME:-~/.codex}.
Claude and Gemini global shims are removed only when requested.

Options:
  -y, --yes          Skip confirmation prompts
  --target DIR       Override CODEX_HOME for this uninstall
  --with-claude      Also remove ~/.claude/CLAUDE.md and ~/.claude/commands andy symlinks
  --with-gemini      Also remove ~/.gemini/GEMINI.md and ~/.gemini/commands andy symlinks
  --all-agents       Enable Claude and Gemini shim removals too
  -h, --help         Show this help
EOF_USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes) FORCE=true; shift ;;
    --target) CODEX_HOME="$2"; shift 2 ;;
    --with-claude) REMOVE_CLAUDE=true; shift ;;
    --with-gemini) REMOVE_GEMINI=true; shift ;;
    --all-agents) REMOVE_CLAUDE=true; REMOVE_GEMINI=true; shift ;;
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
TARGET_DIR="$CODEX_HOME/harnesses/andy"

if [[ ! -d "$CODEX_HOME" ]]; then
  info "CODEX_HOME" "not found; checking optional globals only"
else
  if ! confirm "Remove andy symlinks from $CODEX_HOME?"; then
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

remove_link_if_matches "$CODEX_HOME/AGENTS.md" "$TARGET_DIR/AGENTS.md" "Codex AGENTS.md"
remove_link_if_matches "$CODEX_HOME/andy.config.template.json" "$TARGET_DIR/adapters/fugu/config.template.json" "config template"
remove_link_if_matches "$CODEX_HOME/active-harness" "$TARGET_DIR" "active-harness"

# Remove andy runtime command sets. Any symlink whose target lives under the andy
# harness dir (or repo) is treated as andy-owned and removed.
#
#   $1 dir   runtime command dir (e.g. $CODEX_HOME/prompts)
#   $2 ext   command file extension (md|toml)
#   $3 label log label (e.g. "codex prompt")
remove_command_set() {
  local dir="$1" ext="$2" label="$3" file name
  [[ -d "$dir" ]] || return 0
  for file in "$dir"/*."$ext"; do
    [[ -L "$file" ]] || continue
    name="$(basename "$file")"
    remove_link_if_matches "$file" "$TARGET_DIR/$name" "$label /${name%.*}"
  done
}

# Codex / codex-fugu custom prompts (default install target).
remove_command_set "$CODEX_HOME/prompts" "md" "codex prompt"

remove_link_if_matches "$TARGET_DIR" "$ANDY_ROOT" "harnesses/andy"
LEGACY_ENTRYPOINT="andy"".md"
remove_link_if_matches "$CODEX_HOME/$LEGACY_ENTRYPOINT" "$TARGET_DIR/$LEGACY_ENTRYPOINT" "legacy entrypoint"

if $REMOVE_CLAUDE; then
  remove_link_if_matches "$CLAUDE_HOME/CLAUDE.md" "$TARGET_DIR/CLAUDE.md" "Claude CLAUDE.md"
  remove_command_set "$CLAUDE_HOME/commands" "md" "claude command"
fi
if $REMOVE_GEMINI; then
  remove_link_if_matches "$GEMINI_HOME/GEMINI.md" "$TARGET_DIR/GEMINI.md" "Gemini GEMINI.md"
  remove_command_set "$GEMINI_HOME/commands" "toml" "gemini command"
fi

warn "andy.config.json" "kept if present; remove manually if unwanted: $CODEX_HOME/andy.config.json"
ok "complete" "andy symlink uninstall complete"
