#!/bin/bash
# new-rule.sh — Scaffold a new rule in the current project
set -euo pipefail

KIT_ROOT="${1:?Usage: new-rule.sh <kit-root>}"
shift

TARGET_DIR="$(pwd)"

read -rp "Rule name (lowercase, hyphenated): " RULE_NAME
read -rp "One-line description: " RULE_DESC

cat > "$TARGET_DIR/.claude/rules/${RULE_NAME}.md" <<EOF
## ${RULE_DESC}

### Rule
*(state the rule clearly)*

### Why
*(explain why this rule exists — what incident or pattern prompted it)*

### How to Apply
*(describe when and where this rule kicks in)*
EOF

echo "Created .claude/rules/${RULE_NAME}.md"
