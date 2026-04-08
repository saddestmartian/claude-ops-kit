#!/bin/bash
# check-version.sh — Session-start version check for claude-ops-kit
# Compares project kit version against the installed kit version.
# Outputs upgrade notice with changelog if behind. Exits silently if current.
# Designed to run as a Claude Code SessionStart hook.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST="$PROJECT_DIR/claude-ops.json"

# Require jq — if not available, skip silently
command -v jq &>/dev/null || exit 0
[[ -f "$MANIFEST" ]] || exit 0

PROJECT_VERSION=$(jq -r '.version // "0.0.0"' "$MANIFEST")
KIT_PATH=$(jq -r '.kitPath // ""' "$MANIFEST")
KIT_REPO=$(jq -r '.kitRepo // ""' "$MANIFEST")

KIT_VERSION=""
CHANGELOG_FILE=""

# --- Resolution chain for kit version ---

# 1. Try kitPath from manifest (primary)
if [[ -n "$KIT_PATH" && -f "$KIT_PATH/VERSION" ]]; then
    KIT_VERSION="$(cat "$KIT_PATH/VERSION" | tr -d '[:space:]')"
    CHANGELOG_FILE="$KIT_PATH/CHANGELOG.md"
fi

# 2. Fallback: resolve from claude-ops on PATH (follows symlink on Unix)
if [[ -z "$KIT_VERSION" ]] && command -v claude-ops &>/dev/null; then
    CLAUDE_OPS_PATH="$(command -v claude-ops)"
    REAL_PATH="$(readlink -f "$CLAUDE_OPS_PATH" 2>/dev/null || realpath "$CLAUDE_OPS_PATH" 2>/dev/null || echo "")"
    if [[ -n "$REAL_PATH" ]]; then
        RESOLVED_KIT="$(cd "$(dirname "$REAL_PATH")/.." 2>/dev/null && pwd)"
        if [[ -f "$RESOLVED_KIT/VERSION" ]]; then
            KIT_VERSION="$(cat "$RESOLVED_KIT/VERSION" | tr -d '[:space:]')"
            CHANGELOG_FILE="$RESOLVED_KIT/CHANGELOG.md"
        fi
    fi
fi

# 3. Fallback: check remote via gh
if [[ -z "$KIT_VERSION" && -n "$KIT_REPO" ]] && command -v gh &>/dev/null; then
    KIT_VERSION=$(gh api "repos/$KIT_REPO/releases/latest" --jq '.tag_name' 2>/dev/null | sed 's/^v//' || echo "")
fi

# If we still don't have a kit version, skip silently
[[ -z "$KIT_VERSION" ]] && exit 0

# Same version — nothing to do
[[ "$PROJECT_VERSION" == "$KIT_VERSION" ]] && exit 0

# --- Semver comparison ---
version_gt() {
    local IFS=.
    local i ver1=($1) ver2=($2)
    for ((i = 0; i < 3; i++)); do
        local v1=${ver1[i]:-0} v2=${ver2[i]:-0}
        (( v1 > v2 )) && return 0
        (( v1 < v2 )) && return 1
    done
    return 1
}

# Only notify if kit is ahead of project
version_gt "$KIT_VERSION" "$PROJECT_VERSION" || exit 0

# --- Output upgrade notice ---
echo ""
echo "⚠ claude-ops-kit update available: $PROJECT_VERSION → $KIT_VERSION"
echo ""

# Extract changelog entries between project version and current
if [[ -n "$CHANGELOG_FILE" && -f "$CHANGELOG_FILE" ]]; then
    echo "Changes since $PROJECT_VERSION:"
    echo ""
    awk -v from="$PROJECT_VERSION" '
        /^## \[/ {
            ver = $0
            gsub(/.*\[/, "", ver)
            gsub(/\].*/, "", ver)
            if (ver == from) { exit }
            printing = 1
        }
        printing { print }
    ' "$CHANGELOG_FILE"
    echo ""
fi

echo "Run 'claude-ops upgrade' to update."
echo ""
