#!/bin/bash
# register.sh — Register current project in the cross-project registry
set -euo pipefail

KIT_ROOT="${1:?Usage: register.sh <kit-root>}"
shift

TARGET_DIR="$(pwd)"
MANIFEST="$TARGET_DIR/claude-ops.json"
REGISTRY="$KIT_ROOT/registry/projects.json"

if [[ ! -f "$MANIFEST" ]]; then
    echo "No claude-ops.json found. Run 'claude-ops init' first."
    exit 1
fi

if ! command -v jq &>/dev/null; then
    echo "jq is required for registry operations. Install: brew install jq (or winget install jqlang.jq)"
    exit 1
fi

PROJECT_NAME=$(jq -r '.project.name' "$MANIFEST")
PROJECT_REPO=$(jq -r '.project.repo' "$MANIFEST")
PROJECT_VERSION=$(jq -r '.version' "$MANIFEST")
TODAY=$(date +%Y-%m-%d)

echo "Registering $PROJECT_NAME ($PROJECT_REPO) in kit registry..."

# Check if project already exists
EXISTS=$(jq --arg name "$PROJECT_NAME" '.projects[] | select(.name == $name) | .name' "$REGISTRY" 2>/dev/null)

if [[ -n "$EXISTS" ]]; then
    # Update existing entry
    jq --arg name "$PROJECT_NAME" --arg ver "$PROJECT_VERSION" --arg date "$TODAY" \
        '(.projects[] | select(.name == $name)) |= (.kitVersion = $ver | .lastSync = $date)' \
        "$REGISTRY" > "${REGISTRY}.tmp" && mv "${REGISTRY}.tmp" "$REGISTRY"
    echo "Updated $PROJECT_NAME in registry (version: $PROJECT_VERSION, synced: $TODAY)"
else
    # Add new entry
    STACK=$(jq -c '.project.stack' "$MANIFEST")
    FEATURES=$(jq -c '.features' "$MANIFEST")

    jq --arg name "$PROJECT_NAME" --arg repo "$PROJECT_REPO" \
       --argjson stack "$STACK" --arg ver "$PROJECT_VERSION" --arg date "$TODAY" \
       --argjson features "$FEATURES" \
       '.projects += [{"name": $name, "repo": $repo, "stack": $stack, "kitVersion": $ver, "lastSync": $date, "maturity": "new", "features": $features, "customRules": [], "mcps": []}]' \
       "$REGISTRY" > "${REGISTRY}.tmp" && mv "${REGISTRY}.tmp" "$REGISTRY"
    echo "Added $PROJECT_NAME to registry"
fi
