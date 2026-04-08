#!/bin/bash
# status.sh — Show kit version and project health
set -euo pipefail

KIT_ROOT="${1:?Usage: status.sh <kit-root>}"
shift

TARGET_DIR="$(pwd)"
MANIFEST="$TARGET_DIR/claude-ops.json"

GREEN="\033[0;32m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
BOLD="\033[1m"
RESET="\033[0m"

echo ""
printf "${BOLD}claude-ops status${RESET}\n"
echo ""

# Kit version
KIT_VERSION="$(cat "$KIT_ROOT/VERSION" 2>/dev/null | tr -d '[:space:]' || echo "unknown")"
printf "  Kit version:     ${CYAN}%s${RESET}\n" "$KIT_VERSION"

# Project manifest
if [[ ! -f "$MANIFEST" ]]; then
    printf "  ${YELLOW}⚠ No claude-ops.json found in $(pwd)${RESET}\n"
    printf "  ${YELLOW}  Run 'claude-ops init' to initialize this project.${RESET}\n"
    exit 0
fi

HAS_JQ=true
if ! command -v jq &>/dev/null; then
    HAS_JQ=false
    echo "  (install jq for detailed status)"
fi

if $HAS_JQ; then
    PROJECT_NAME=$(jq -r '.project.name' "$MANIFEST")
    PROJECT_VERSION=$(jq -r '.version' "$MANIFEST")
    STACK=$(jq -r '.project.stack | join(", ")' "$MANIFEST")
    LAST_UPGRADE=$(jq -r '.lastUpgrade' "$MANIFEST")

    printf "  Project:         ${GREEN}%s${RESET}\n" "$PROJECT_NAME"
    printf "  Project version: %s\n" "$PROJECT_VERSION"
    printf "  Stack:           %s\n" "$STACK"
    printf "  Last upgrade:    %s\n" "$LAST_UPGRADE"
    echo ""

    # Features
    printf "  ${BOLD}Features:${RESET}\n"
    for feature in backlog domains testing dependencyGraph retrospectives; do
        val=$(jq -r ".features.$feature" "$MANIFEST")
        if [[ "$val" == "true" ]]; then
            printf "    ${GREEN}✓${RESET} %s\n" "$feature"
        else
            printf "    · %s\n" "$feature"
        fi
    done

    # Agents
    AGENTS=$(jq -r '.features.agents | join(", ")' "$MANIFEST" 2>/dev/null)
    if [[ -n "$AGENTS" && "$AGENTS" != "" ]]; then
        printf "    ${GREEN}✓${RESET} agents: %s\n" "$AGENTS"
    fi

    # Skills
    SKILLS=$(jq -r '.features.skills | join(", ")' "$MANIFEST" 2>/dev/null)
    printf "    ${GREEN}✓${RESET} skills: %s\n" "$SKILLS"
fi

# File health
echo ""
printf "  ${BOLD}File Health:${RESET}\n"
for f in CLAUDE.md PROJECT_STATE.md REFERENCE_MAP.md .claude/MEMORY.md .githooks/pre-commit scripts/sync-memory.sh; do
    if [[ -f "$TARGET_DIR/$f" ]]; then
        printf "    ${GREEN}✓${RESET} %s\n" "$f"
    else
        printf "    ${YELLOW}⚠${RESET} %s (missing)\n" "$f"
    fi
done

# Rules count
RULE_COUNT=$(ls -1 "$TARGET_DIR/.claude/rules/"*.md 2>/dev/null | wc -l | tr -d ' ')
printf "    ${GREEN}✓${RESET} .claude/rules/ (%s rules)\n" "$RULE_COUNT"

# Discovered (unmanaged) files
if $HAS_JQ && [[ -f "$MANIFEST" ]]; then
    DISCOVERED_COUNT=$(jq -r '.discovered // [] | length' "$MANIFEST" 2>/dev/null || echo "0")
    if [[ "$DISCOVERED_COUNT" -gt 0 ]]; then
        echo ""
        printf "  ${BOLD}Discovered (Unmanaged):${RESET}\n"
        for ((i = 0; i < DISCOVERED_COUNT; i++)); do
            DPATH=$(jq -r ".discovered[$i].path" "$MANIFEST")
            DACTION=$(jq -r ".discovered[$i].action" "$MANIFEST")
            DISSUE=$(jq -r ".discovered[$i].issueUrl // \"\"" "$MANIFEST")
            case "$DACTION" in
                keep)
                    if [[ -n "$DISSUE" ]]; then
                        printf "    ${GREEN}✓${RESET} %s (kept — %s)\n" "$DPATH" "$DISSUE"
                    else
                        printf "    ${GREEN}✓${RESET} %s (kept)\n" "$DPATH"
                    fi
                    ;;
                ignore)
                    printf "    · %s (ignored)\n" "$DPATH"
                    ;;
            esac
        done
    fi
fi

echo ""
