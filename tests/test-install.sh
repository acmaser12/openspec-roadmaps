#!/usr/bin/env bash
set -euo pipefail

PACK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL="$PACK_ROOT/install.sh"
SKILLS=(roadmap-propose roadmap-next roadmap-status roadmap-update)
FAILS=0

assert() {
  local message="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "ok - $message"
  else
    echo "not ok - $message" >&2
    FAILS=$((FAILS + 1))
  fi
}

assert_eq() {
  local message="$1"
  local expected="$2"
  local actual="$3"
  if [[ "$expected" == "$actual" ]]; then
    echo "ok - $message"
  else
    echo "not ok - $message" >&2
    echo "         expected: $expected" >&2
    echo "         actual:   $actual" >&2
    FAILS=$((FAILS + 1))
  fi
}

TMP="$(mktemp -d "${TMPDIR:-/tmp}/openspec-roadmaps-test.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

# Missing git repo should fail.
mkdir -p "$TMP/not-git/openspec"
if "$INSTALL" --target "$TMP/not-git" >/dev/null 2>"$TMP/not-git.err"; then
  echo "not ok - rejects a non-git target" >&2
  FAILS=$((FAILS + 1))
else
  echo "ok - rejects a non-git target"
fi

# Git repo without openspec/ should fail unless --force.
mkdir -p "$TMP/no-openspec"
git -C "$TMP/no-openspec" init -q
if "$INSTALL" --target "$TMP/no-openspec" >/dev/null 2>"$TMP/no-openspec.err"; then
  echo "not ok - rejects a git repo without openspec/" >&2
  FAILS=$((FAILS + 1))
else
  echo "ok - rejects a git repo without openspec/"
fi

# --force installs into a git repo without openspec/.
"$INSTALL" --target "$TMP/no-openspec" --force >/dev/null
assert "force install creates canonical propose skill" test -f "$TMP/no-openspec/.agent-shared/skills/roadmap-propose/SKILL.md"

# Happy path.
PROJECT="$TMP/project"
mkdir -p "$PROJECT/openspec/changes" "$PROJECT/openspec/roadmaps"
git -C "$PROJECT" init -q
printf '%s\n' '# keep me' > "$PROJECT/openspec/roadmaps/README.md"

"$INSTALL" --target "$PROJECT" >/dev/null

for skill in "${SKILLS[@]}"; do
  assert "$skill canonical SKILL.md exists" test -f "$PROJECT/.agent-shared/skills/$skill/SKILL.md"
  assert "$skill is not a symlink in .agent-shared" test ! -L "$PROJECT/.agent-shared/skills/$skill"
  assert "Cursor $skill is a symlink" test -L "$PROJECT/.cursor/skills/$skill"
  assert "Claude $skill is a symlink" test -L "$PROJECT/.claude/skills/$skill"
  assert_eq "Cursor $skill relative target" \
    "../../.agent-shared/skills/$skill" \
    "$(readlink "$PROJECT/.cursor/skills/$skill")"
  assert_eq "Claude $skill relative target" \
    "../../.agent-shared/skills/$skill" \
    "$(readlink "$PROJECT/.claude/skills/$skill")"
done

assert "canonical triage rule is a real file" test -f "$PROJECT/.agent-shared/rules/roadmap-triage.md"
assert "canonical triage rule is not a symlink" test ! -L "$PROJECT/.agent-shared/rules/roadmap-triage.md"
assert "Cursor triage rule is a symlink" test -L "$PROJECT/.cursor/rules/roadmap-triage.mdc"
assert "Claude triage rule is a symlink" test -L "$PROJECT/.claude/rules/roadmap-triage.md"
assert_eq "Cursor triage relative target" \
  "../../.agent-shared/rules/roadmap-triage.md" \
  "$(readlink "$PROJECT/.cursor/rules/roadmap-triage.mdc")"
assert_eq "Claude triage relative target" \
  "../../.agent-shared/rules/roadmap-triage.md" \
  "$(readlink "$PROJECT/.claude/rules/roadmap-triage.md")"

assert "workflow doc is installed canonically" test -f "$PROJECT/.agent-shared/docs/roadmap-workflow.md"
assert "source stamp exists" test -f "$PROJECT/.agent-shared/openspec-roadmaps.source"
assert_eq "existing roadmaps README is preserved" \
  "# keep me" \
  "$(cat "$PROJECT/openspec/roadmaps/README.md")"

# Generated OpenSpec skills must be left alone.
mkdir -p "$PROJECT/.cursor/skills/openspec-propose" "$PROJECT/.claude/skills/openspec-propose"
printf '%s\n' 'generated' > "$PROJECT/.cursor/skills/openspec-propose/SKILL.md"
printf '%s\n' 'generated' > "$PROJECT/.claude/skills/openspec-propose/SKILL.md"

# Idempotent second run, and extra shared files stay.
mkdir -p "$PROJECT/.agent-shared/skills/unrelated"
printf '%s\n' 'leave me' > "$PROJECT/.agent-shared/skills/unrelated/SKILL.md"
"$INSTALL" --target "$PROJECT" >/dev/null

assert "second run keeps extra shared skill" test -f "$PROJECT/.agent-shared/skills/unrelated/SKILL.md"
assert_eq "second run does not touch Cursor openspec-propose" \
  "generated" \
  "$(cat "$PROJECT/.cursor/skills/openspec-propose/SKILL.md")"
assert_eq "second run does not touch Claude openspec-propose" \
  "generated" \
  "$(cat "$PROJECT/.claude/skills/openspec-propose/SKILL.md")"
assert "second run still uses relative Cursor symlink" test -L "$PROJECT/.cursor/skills/roadmap-propose"

if [[ "$FAILS" -ne 0 ]]; then
  echo "$FAILS assertion(s) failed" >&2
  exit 1
fi

echo "All assertions passed"
