#!/bin/bash
# seed.sh — Drop the /claude-ops-kit skill into a project so the onboarding
# conversation can begin. This is the minimum viable bootstrap — the skill
# handles everything else.
#
# Usage (from your project directory):
#   bash /path/to/claude-ops-kit/bin/seed.sh
#
# Or with explicit kit path:
#   CLAUDE_OPS_KIT=/path/to/kit bash seed.sh

set -euo pipefail

# Resolve kit root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT="${CLAUDE_OPS_KIT:-$(cd "$SCRIPT_DIR/.." && pwd)}"

SKILL_SRC="$KIT_ROOT/templates/baseline/claude/skills/claude-ops-kit"
TARGET_DIR="$(pwd)"
SKILL_DEST="$TARGET_DIR/.claude/skills/claude-ops-kit"

if [[ ! -d "$SKILL_SRC" ]]; then
    echo "Error: Could not find skill at $SKILL_SRC"
    echo "Set CLAUDE_OPS_KIT to the kit root directory."
    exit 1
fi

if [[ -d "$SKILL_DEST" ]]; then
    echo "Skill already installed at $SKILL_DEST"
    echo "Open Claude Code and run /claude-ops-kit"
    exit 0
fi

mkdir -p "$SKILL_DEST/procedures"
cp "$SKILL_SRC/SKILL.md" "$SKILL_DEST/SKILL.md"
cp "$SKILL_SRC/procedures/"*.md "$SKILL_DEST/procedures/"

echo "Seeded /claude-ops-kit skill into .claude/skills/"
echo ""
echo "Next: Open Claude Code in this project and run /claude-ops-kit"
