#!/bin/bash
# new-skill.sh — Scaffold a new skill in the current project
set -euo pipefail

KIT_ROOT="${1:?Usage: new-skill.sh <kit-root>}"
shift

TARGET_DIR="$(pwd)"

read -rp "Skill name (lowercase, hyphenated): " SKILL_NAME
read -rp "One-line description: " SKILL_DESC
read -rp "Simple file or directory? [file/dir]: " SKILL_TYPE

if [[ "$SKILL_TYPE" == "dir" ]]; then
    mkdir -p "$TARGET_DIR/.claude/skills/$SKILL_NAME"
    cat > "$TARGET_DIR/.claude/skills/$SKILL_NAME/SKILL.md" <<EOF
# Skill: ${SKILL_NAME}

## When to Use
${SKILL_DESC}

## Procedure

### Step 1: Gather Context
- *(describe what to read/check first)*

### Step 2: Execute
- *(describe the main action)*

### Step 3: Verify
- *(describe how to verify success)*

## Rules
- *(constraints and guardrails)*
EOF
    echo "Created .claude/skills/$SKILL_NAME/SKILL.md"
else
    cat > "$TARGET_DIR/.claude/skills/skill_${SKILL_NAME}.md" <<EOF
# ${SKILL_NAME} — Skill Guide

## When to Load
${SKILL_DESC}

## Patterns

### Pattern 1
\`\`\`
*(code or workflow pattern)*
\`\`\`

## Rules
- *(constraints and guardrails)*
EOF
    echo "Created .claude/skills/skill_${SKILL_NAME}.md"
fi
