#!/usr/bin/env bash
# Install OpenSpec roadmap skills and the always-on triage rule into a project.
# Canonical files go in .agent-shared/; Cursor and Claude get relative symlinks.
set -euo pipefail

PACK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$(pwd)"
FORCE=0
SKILLS=(roadmap-propose roadmap-next roadmap-status roadmap-update)

usage() {
  cat <<'EOF'
Install OpenSpec roadmap skills and triage rule into a project.

Usage:
  install.sh [--target DIR] [--force]

Options:
  --target DIR   Project to install into (default: current directory)
  --force        Continue even when the target has no openspec/ directory
  -h, --help     Show this help

Canonical files are copied to .agent-shared/. Relative symlinks are created
under .cursor/ and .claude/. Re-running updates pack-owned paths only.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      [[ $# -ge 2 ]] || { echo "error: --target requires a directory" >&2; exit 2; }
      TARGET="$2"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ ! -d "$TARGET" ]]; then
  echo "error: target is not a directory: $TARGET" >&2
  exit 1
fi
TARGET="$(cd "$TARGET" && pwd)"

if ! git -C "$TARGET" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "error: target is not a git repository: $TARGET" >&2
  exit 1
fi

if [[ ! -d "$TARGET/openspec" ]]; then
  if [[ "$FORCE" -eq 0 ]]; then
    echo "error: $TARGET has no openspec/ directory (OpenSpec project required)." >&2
    echo "       Re-run with --force if you still want to install." >&2
    exit 1
  fi
  echo "warning: $TARGET has no openspec/ directory; installing anyway because --force was set." >&2
fi

link_rel() {
  local dest="$1"
  local rel_target="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ -L "$dest" || -e "$dest" ]]; then
    rm -rf "$dest"
  fi
  ln -sfn "$rel_target" "$dest"
}

mkdir -p \
  "$TARGET/.agent-shared/skills" \
  "$TARGET/.agent-shared/rules" \
  "$TARGET/.agent-shared/docs"

for skill in "${SKILLS[@]}"; do
  rm -rf "$TARGET/.agent-shared/skills/$skill"
  cp -R "$PACK_ROOT/skills/$skill" "$TARGET/.agent-shared/skills/$skill"
done

cp "$PACK_ROOT/rules/roadmap-triage.md" "$TARGET/.agent-shared/rules/roadmap-triage.md"
cp "$PACK_ROOT/docs/roadmap-workflow.md" "$TARGET/.agent-shared/docs/roadmap-workflow.md"

for skill in "${SKILLS[@]}"; do
  link_rel "$TARGET/.cursor/skills/$skill" "../../.agent-shared/skills/$skill"
  link_rel "$TARGET/.claude/skills/$skill" "../../.agent-shared/skills/$skill"
done

link_rel "$TARGET/.cursor/rules/roadmap-triage.mdc" "../../.agent-shared/rules/roadmap-triage.md"
link_rel "$TARGET/.claude/rules/roadmap-triage.md" "../../.agent-shared/rules/roadmap-triage.md"

if [[ ! -e "$TARGET/openspec/roadmaps/README.md" ]]; then
  mkdir -p "$TARGET/openspec/roadmaps"
  cp "$PACK_ROOT/templates/openspec/roadmaps/README.md" "$TARGET/openspec/roadmaps/README.md"
fi

REPO="$(git -C "$PACK_ROOT" remote get-url origin 2>/dev/null || echo "adammaser/openspec-roadmaps")"
COMMIT="$(git -C "$PACK_ROOT" rev-parse HEAD 2>/dev/null || echo "uncommitted")"
INSTALLED="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
cat > "$TARGET/.agent-shared/openspec-roadmaps.source" <<EOF
repo: $REPO
commit: $COMMIT
installed: $INSTALLED
EOF

echo "Installed OpenSpec roadmap pack into $TARGET"
echo "  canonical: .agent-shared/skills, .agent-shared/rules, .agent-shared/docs"
echo "  Cursor:    .cursor/skills/roadmap-*  .cursor/rules/roadmap-triage.mdc"
echo "  Claude:    .claude/skills/roadmap-*  .claude/rules/roadmap-triage.md"
echo "  source:    .agent-shared/openspec-roadmaps.source ($COMMIT)"
