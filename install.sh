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
The Codex/codex-fugu workflow commands (/brainstorm, /spec, ...) are installed by
default. Claude and Gemini (Gemini also covers Antigravity) shims and commands
are opt-in.

Options:
  -y, --yes          Skip confirmation prompts
  --no-active        Do not create ~/.codex/active-harness
  --target DIR       Override CODEX_HOME for this install
  --with-claude      Also link ~/.claude/CLAUDE.md and ~/.claude/commands/*.md
  --with-gemini      Also link ~/.gemini/GEMINI.md and ~/.gemini/commands/*.toml
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

# Install runtime command sets. Each set links workflow command files from a
# runtime adapter into that runtime's user-level command directory. `core/`
# stays runtime-neutral; only adapters know the per-runtime command format.
#
#   $1 src_dir   adapter command dir inside the andy repo (e.g. adapters/codex/prompts)
#   $2 dest_dir  runtime command dir (e.g. $CODEX_HOME/prompts)
#   $3 ext       command file extension to link (md|toml)
#   $4 label     human label for log lines (e.g. "codex prompt")
install_command_set() {
  local src_dir="$1" dest_dir="$2" ext="$3" label="$4"
  [[ -d "$ANDY_ROOT/$src_dir" ]] || { warn "$label" "no adapter dir: $src_dir"; return 0; }
  mkdir -p "$dest_dir"
  local file name cmd_name
  for file in "$ANDY_ROOT/$src_dir"/*."$ext"; do
    [[ -e "$file" ]] || continue
    name="$(basename "$file")"
    [[ "$name" == "README.$ext" ]] && continue
    cmd_name="${name%.*}"
    link_path "$TARGET_DIR/$src_dir/$name" "$dest_dir/$name" "$label /$cmd_name"
  done
}

# Codex / codex-fugu custom prompts (default install target).
# Codex scans only top-level Markdown files in $CODEX_HOME/prompts.
install_command_set "adapters/codex/prompts" "$CODEX_HOME/prompts" "md" "codex prompt"

if [[ ! -f "$CODEX_HOME/andy.config.json" ]]; then
  cp "$ANDY_ROOT/adapters/fugu/config.template.json" "$CODEX_HOME/andy.config.json"
  ok "andy.config.json" "created from template"
else
  warn "andy.config.json" "already exists; not overwritten"
fi

if $INSTALL_CLAUDE; then
  link_path "$TARGET_DIR/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md" "Claude CLAUDE.md"
  install_command_set "adapters/claude/commands" "$CLAUDE_HOME/commands" "md" "claude command"
fi
if $INSTALL_GEMINI; then
  link_path "$TARGET_DIR/GEMINI.md" "$GEMINI_HOME/GEMINI.md" "Gemini GEMINI.md"
  # Gemini CLI and Antigravity share the same custom-command format.
  install_command_set "adapters/gemini/commands" "$GEMINI_HOME/commands" "toml" "gemini command"
fi

"$ANDY_ROOT/scripts/validate-harness.sh" "$ANDY_ROOT"

echo
ok "complete" "andy installed into $CODEX_HOME"
info "slash commands" "try: /brainstorm issue #123  (or plain: brainstorm issue #123)"
if $INSTALL_CLAUDE; then info "claude commands" "installed into $CLAUDE_HOME/commands"; fi
if $INSTALL_GEMINI; then info "gemini commands" "installed into $GEMINI_HOME/commands (covers Antigravity)"; fi
