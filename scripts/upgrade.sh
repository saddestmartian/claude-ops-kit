#!/bin/bash
# upgrade.sh — Pull updated templates from kit into current project
set -euo pipefail

KIT_ROOT="${1:?Usage: upgrade.sh <kit-root>}"
shift

TARGET_DIR="$(pwd)"
MANIFEST="$TARGET_DIR/claude-ops.json"

GREEN="\033[0;32m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
BOLD="\033[1m"
RESET="\033[0m"

if [[ ! -f "$MANIFEST" ]]; then
    echo "No claude-ops.json found. Run 'claude-ops init' first."
    exit 1
fi

if ! command -v jq &>/dev/null; then
    echo "jq is required. Install: brew install jq (or winget install jqlang.jq)"
    exit 1
fi

PROJECT_VERSION=$(jq -r '.version' "$MANIFEST")
KIT_VERSION="1.0.0"  # Read from kit's version file in production

printf "${BOLD}claude-ops upgrade${RESET}\n"
printf "  Project version: %s\n" "$PROJECT_VERSION"
printf "  Kit version:     %s\n" "$KIT_VERSION"
echo ""

if [[ "$PROJECT_VERSION" == "$KIT_VERSION" ]]; then
    printf "${GREEN}Already up to date.${RESET}\n"
    exit 0
fi

# Compare baseline rules
printf "${BOLD}Checking baseline rules...${RESET}\n"
BASELINE_RULES="$KIT_ROOT/templates/baseline/claude/rules"
PROJECT_RULES="$TARGET_DIR/.claude/rules"

updated=0
added=0
skipped=0

for rule_file in "$BASELINE_RULES"/*.md; do
    rule_name=$(basename "$rule_file")
    project_rule="$PROJECT_RULES/$rule_name"

    if [[ ! -f "$project_rule" ]]; then
        # New rule — add it
        cp "$rule_file" "$project_rule"
        printf "  ${GREEN}+ Added${RESET}: %s\n" "$rule_name"
        added=$((added + 1))
    else
        # Check if user modified it
        if diff -q "$rule_file" "$project_rule" &>/dev/null; then
            # Identical — could update if kit changed (compare against old kit version)
            : # no-op for now
        else
            printf "  ${YELLOW}~ Skipped${RESET}: %s (user-modified)\n" "$rule_name"
            skipped=$((skipped + 1))
        fi
    fi
done

# Update manifest version
TODAY=$(date +%Y-%m-%d)
jq --arg ver "$KIT_VERSION" --arg date "$TODAY" \
    '.version = $ver | .lastUpgrade = $date' \
    "$MANIFEST" > "${MANIFEST}.tmp" && mv "${MANIFEST}.tmp" "$MANIFEST"

echo ""
printf "${BOLD}Summary:${RESET}\n"
printf "  Added:   %d\n" "$added"
printf "  Skipped: %d (user-modified)\n" "$skipped"
printf "  Version: %s → %s\n" "$PROJECT_VERSION" "$KIT_VERSION"
echo ""
printf "${GREEN}Upgrade complete.${RESET}\n"
