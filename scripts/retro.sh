#!/bin/bash
# retro.sh — Generate a retrospective template for the current session
set -euo pipefail

KIT_ROOT="${1:?Usage: retro.sh <kit-root>}"
shift

TARGET_DIR="$(pwd)"
TODAY=$(date +%Y-%m-%d)
RETRO_DIR="$TARGET_DIR/.claude/retrospectives"
RETRO_FILE="$RETRO_DIR/retro-${TODAY}.md"

mkdir -p "$RETRO_DIR"

if [[ -f "$RETRO_FILE" ]]; then
    echo "Retrospective for today already exists: $RETRO_FILE"
    exit 0
fi

# Get recent git log for context
RECENT_LOG=""
if git rev-parse --is-inside-work-tree &>/dev/null; then
    RECENT_LOG=$(git log --oneline -10 2>/dev/null || echo "(no commits)")
fi

cat > "$RETRO_FILE" <<EOF
# Session Retrospective — ${TODAY}

## Session Info
- **Date:** ${TODAY}
- **Branch:** $(git branch --show-current 2>/dev/null || echo "unknown")

## Recent Commits
\`\`\`
${RECENT_LOG}
\`\`\`

## What Worked
-

## What Didn't Work
-

## What I Learned
-

## Confidence Assessment
- **Overall session quality:** ⭐⭐⭐⭐⭐ (1-5)
- **Code confidence:** HIGH / MEDIUM / LOW

## Action Items
- [ ]

## Patterns to Remember
-
EOF

echo "Created retrospective: $RETRO_FILE"
