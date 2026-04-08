#!/bin/bash
# new-agent.sh — Scaffold a new agent in the current project
set -euo pipefail

KIT_ROOT="${1:?Usage: new-agent.sh <kit-root>}"
shift

TARGET_DIR="$(pwd)"

read -rp "Agent name (lowercase, hyphenated): " AGENT_NAME
read -rp "One-line purpose: " AGENT_PURPOSE
read -rp "Model [sonnet/opus]: " AGENT_MODEL
AGENT_MODEL="${AGENT_MODEL:-sonnet}"

mkdir -p "$TARGET_DIR/.claude/agents/$AGENT_NAME"

cat > "$TARGET_DIR/.claude/agents/$AGENT_NAME/CLAUDE.md" <<EOF
---
model: ${AGENT_MODEL}
---

# ${AGENT_NAME} Agent

${AGENT_PURPOSE}

## What to Check

1. **Check 1**
   - *(describe what to look for)*
   - Report: findings with file paths and line numbers

2. **Check 2**
   - *(describe what to look for)*
   - Report: findings with file paths and line numbers

## Output Format

\`\`\`
OVERALL: PASS | WARN | FAIL

## Findings
- [file:line] Description
\`\`\`

## Rules
- Read-only — do NOT modify any files
- Verify findings by reading actual source
- FAIL only for critical issues
- WARN for non-critical issues
EOF

echo "Created .claude/agents/$AGENT_NAME/CLAUDE.md"
