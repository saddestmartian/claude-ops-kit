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
RED="\033[0;31m"
BOLD="\033[1m"
DIM="\033[2m"
RESET="\033[0m"

# Parse flags
NO_DISCOVER=false
for arg in "$@"; do
    case "$arg" in
        --no-discover) NO_DISCOVER=true ;;
    esac
done

# Shared discovery library
source "$KIT_ROOT/scripts/lib/discovery.sh"

info()  { printf "${CYAN}→ %s${RESET}\n" "$1"; }
ok()    { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
warn()  { printf "${YELLOW}⚠ %s${RESET}\n" "$1"; }
header() { printf "\n${BOLD}%s${RESET}\n" "$1"; }

if [[ ! -f "$MANIFEST" ]]; then
    echo "No claude-ops.json found. Run 'claude-ops init' first."
    exit 1
fi

if ! command -v jq &>/dev/null; then
    echo "jq is required. Install: brew install jq (or winget install jqlang.jq)"
    exit 1
fi

PROJECT_VERSION=$(jq -r '.version' "$MANIFEST")
KIT_VERSION="$(cat "$KIT_ROOT/VERSION" 2>/dev/null | tr -d '[:space:]' || echo "unknown")"

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

# Discover unknown .claude/ files
PROJECT_NAME=$(jq -r '.project.name // "unknown"' "$MANIFEST" 2>/dev/null || echo "unknown")
run_discovery "$KIT_ROOT" "$TARGET_DIR" "$PROJECT_NAME" "$NO_DISCOVER"

# Update check-version.sh to latest
BASELINE="$KIT_ROOT/templates/baseline"
if [[ -f "$BASELINE/scripts/check-version.sh" ]]; then
    cp "$BASELINE/scripts/check-version.sh" "$TARGET_DIR/scripts/check-version.sh"
    chmod +x "$TARGET_DIR/scripts/check-version.sh"
    printf "  ${GREEN}+ Updated${RESET}: scripts/check-version.sh\n"
fi

# Ensure SessionStart hook exists
SETTINGS_FILE="$TARGET_DIR/.claude/settings.json"
HOOK_CMD="bash scripts/check-version.sh"
if [[ -f "$SETTINGS_FILE" ]]; then
    if ! jq -e ".hooks.SessionStart[]?.hooks[]? | select(.command == \"$HOOK_CMD\")" "$SETTINGS_FILE" &>/dev/null; then
        jq --arg cmd "$HOOK_CMD" '.hooks = (.hooks // {}) | .hooks.SessionStart = ((.hooks.SessionStart // []) + [{"matcher": "", "hooks": [{"type": "command", "command": $cmd, "timeout": 5000}]}])' \
            "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp" && mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"
        printf "  ${GREEN}+ Added${RESET}: version check hook to .claude/settings.json\n"
    fi
elif [[ ! -f "$SETTINGS_FILE" ]]; then
    mkdir -p "$TARGET_DIR/.claude"
    cat > "$SETTINGS_FILE" <<'SETTINGSJSON'
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash scripts/check-version.sh",
            "timeout": 5000
          }
        ]
      }
    ]
  }
}
SETTINGSJSON
    printf "  ${GREEN}+ Created${RESET}: .claude/settings.json with version check hook\n"
fi

# Update manifest version and kitPath
TODAY=$(date +%Y-%m-%d)
jq --arg ver "$KIT_VERSION" --arg date "$TODAY" --arg kp "$KIT_ROOT" \
    '.version = $ver | .lastUpgrade = $date | .kitPath = $kp' \
    "$MANIFEST" > "${MANIFEST}.tmp" && mv "${MANIFEST}.tmp" "$MANIFEST"

echo ""
printf "${BOLD}Summary:${RESET}\n"
printf "  Added:   %d\n" "$added"
printf "  Skipped: %d (user-modified)\n" "$skipped"
printf "  Version: %s → %s\n" "$PROJECT_VERSION" "$KIT_VERSION"
echo ""
printf "${GREEN}Upgrade complete.${RESET}\n"
