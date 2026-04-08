#!/bin/bash
# adopt.sh — Integrate claude-ops-kit into an existing project with Claude Code setup
# Unlike init (blank slate) or upgrade (already kit-managed), adopt handles projects
# that have some existing Claude Code files but weren't bootstrapped by the kit.
set -euo pipefail

KIT_ROOT="${1:?Usage: adopt.sh <kit-root>}"
shift

VERSION="1.0.0"
TARGET_DIR="$(pwd)"

# Colors
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
BOLD="\033[1m"
DIM="\033[2m"
RESET="\033[0m"

info()   { printf "${CYAN}→ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
warn()   { printf "${YELLOW}⚠ %s${RESET}\n" "$1"; }
skip()   { printf "${DIM}  · %s${RESET}\n" "$1"; }
header() { printf "\n${BOLD}%s${RESET}\n" "$1"; }

# ---------------------------------------------------------------------------
# Phase 1: Pre-flight checks
# ---------------------------------------------------------------------------
header "claude-ops adopt v${VERSION}"

if [[ -f "$TARGET_DIR/claude-ops.json" ]]; then
    echo "This project already has a claude-ops.json manifest."
    echo "Use 'claude-ops upgrade' to update templates."
    exit 1
fi

if [[ ! -d "$TARGET_DIR/.git" ]]; then
    echo "Not a git repository. Run 'git init' first."
    exit 1
fi

# ---------------------------------------------------------------------------
# Phase 2: Scan existing setup
# ---------------------------------------------------------------------------
header "Scanning existing Claude Code setup..."

declare -A EXISTING
SCAN_ITEMS=(
    "CLAUDE.md"
    "PROJECT_STATE.md"
    "REFERENCE_MAP.md"
    "DOMAINS.md"
    "backlog.json"
    "backlog-viewer.html"
    ".claude/MEMORY.md"
    ".claude/rules"
    ".claude/skills"
    ".claude/agents"
    ".claude/setup"
    ".githooks/pre-commit"
    "scripts/sync-memory.sh"
    "scripts/verify-sync.sh"
)

found_count=0
for item in "${SCAN_ITEMS[@]}"; do
    if [[ -f "$TARGET_DIR/$item" || -d "$TARGET_DIR/$item" ]]; then
        EXISTING["$item"]=true
        printf "  ${GREEN}✓${RESET} %s\n" "$item"
        found_count=$((found_count + 1))
    else
        printf "  ${DIM}·${RESET} %s ${DIM}(not found)${RESET}\n" "$item"
        EXISTING["$item"]=false
    fi
done

echo ""
echo "  Found $found_count existing items."

# Count existing rules if directory exists
existing_rules=0
if [[ -d "$TARGET_DIR/.claude/rules" ]]; then
    existing_rules=$(ls -1 "$TARGET_DIR/.claude/rules/"*.md 2>/dev/null | wc -l | tr -d ' ')
    echo "  Existing rules: $existing_rules"
fi

existing_skills=0
if [[ -d "$TARGET_DIR/.claude/skills" ]]; then
    existing_skills=$(find "$TARGET_DIR/.claude/skills" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    echo "  Existing skills: $existing_skills"
fi

# ---------------------------------------------------------------------------
# Phase 3: Collect project metadata
# ---------------------------------------------------------------------------
header "Project Configuration"

DEFAULT_NAME=$(basename "$TARGET_DIR")
read -rp "Project name [${DEFAULT_NAME}]: " PROJECT_NAME
PROJECT_NAME="${PROJECT_NAME:-$DEFAULT_NAME}"

DEFAULT_PREFIX=$(echo "$PROJECT_NAME" | tr '[:lower:]' '[:upper:]' | cut -c1-3)
read -rp "Task ID prefix [${DEFAULT_PREFIX}]: " TASK_PREFIX
TASK_PREFIX="${TASK_PREFIX:-$DEFAULT_PREFIX}"

echo ""
echo "Tech stacks (comma-separated):"
echo "  nodejs, typescript, swift, python, luau, other"
read -rp "Stack [nodejs]: " TECH_STACK
TECH_STACK="${TECH_STACK:-nodejs}"

GITHUB_ORG=""
if git remote get-url origin &>/dev/null; then
    GITHUB_ORG=$(git remote get-url origin | sed -E 's#.*[:/]([^/]+)/[^/]+\.git$#\1#' 2>/dev/null || echo "")
fi
read -rp "GitHub org/user [${GITHUB_ORG:-your-org}]: " INPUT_ORG
GITHUB_ORG="${INPUT_ORG:-${GITHUB_ORG:-your-org}}"

read -rp "Source directory [src/]: " SOURCE_DIR
SOURCE_DIR="${SOURCE_DIR:-src/}"

case "$TECH_STACK" in
    *typescript*) DEFAULT_EXT=".ts" ;;
    *swift*)      DEFAULT_EXT=".swift" ;;
    *python*)     DEFAULT_EXT=".py" ;;
    *luau*)       DEFAULT_EXT=".luau" ;;
    *)            DEFAULT_EXT=".js" ;;
esac
read -rp "Primary file extension [${DEFAULT_EXT}]: " FILE_EXTENSION
FILE_EXTENSION="${FILE_EXTENSION:-$DEFAULT_EXT}"

case "$TECH_STACK" in
    *typescript*|*nodejs*) DEFAULT_LINT="npx eslint ."; DEFAULT_FORMAT="npx prettier --check ."; DEFAULT_TEST="npm test" ;;
    *swift*) DEFAULT_LINT="swiftlint"; DEFAULT_FORMAT="swiftformat --lint ."; DEFAULT_TEST="swift test" ;;
    *python*) DEFAULT_LINT="ruff check ."; DEFAULT_FORMAT="ruff format --check ."; DEFAULT_TEST="pytest" ;;
    *luau*) DEFAULT_LINT="selene src/"; DEFAULT_FORMAT="stylua --check src/"; DEFAULT_TEST="echo 'Tests run via Roblox Studio playtest'" ;;
    *) DEFAULT_LINT="echo 'No lint configured'"; DEFAULT_FORMAT="echo 'No formatter configured'"; DEFAULT_TEST="echo 'No tests configured'" ;;
esac

read -rp "Lint command [${DEFAULT_LINT}]: " LINT_CMD
LINT_CMD="${LINT_CMD:-$DEFAULT_LINT}"
read -rp "Format command [${DEFAULT_FORMAT}]: " FORMAT_CMD
FORMAT_CMD="${FORMAT_CMD:-$DEFAULT_FORMAT}"
read -rp "Test command [${DEFAULT_TEST}]: " TEST_CMD
TEST_CMD="${TEST_CMD:-$DEFAULT_TEST}"

# ---------------------------------------------------------------------------
# Phase 4: Per-component merge decisions
# ---------------------------------------------------------------------------
header "Merge Decisions"
echo "For each component, choose: [m]erge, [s]kip, or [r]eplace"
echo "  merge   = add kit content alongside existing (rules, skills, etc.)"
echo "  skip    = keep existing, don't touch"
echo "  replace = overwrite with kit template"
echo ""

TODAY=$(date +%Y-%m-%d)
PRIMARY_STACK=$(echo "$TECH_STACK" | cut -d',' -f1 | tr -d ' ')

# Template substitution function
render_template() {
    local src="$1"
    local dest="$2"
    sed -e "s|{{PROJECT_NAME}}|${PROJECT_NAME}|g" \
        -e "s|{{PROJECT_DESCRIPTION}}|Managed with claude-ops-kit|g" \
        -e "s|{{TASK_PREFIX}}|${TASK_PREFIX}|g" \
        -e "s|{{TECH_STACK}}|${TECH_STACK}|g" \
        -e "s|{{GITHUB_ORG}}|${GITHUB_ORG}|g" \
        -e "s|{{SOURCE_DIR}}|${SOURCE_DIR}|g" \
        -e "s|{{FILE_EXTENSION}}|${FILE_EXTENSION}|g" \
        -e "s|{{LINT_CMD}}|${LINT_CMD}|g" \
        -e "s|{{FORMAT_CMD}}|${FORMAT_CMD}|g" \
        -e "s|{{TEST_CMD}}|${TEST_CMD}|g" \
        -e "s|{{DATE}}|${TODAY}|g" \
        -e "s|{{KIT_VERSION}}|${VERSION}|g" \
        -e "s|{{ACTIVE_PHASE}}|Adopted from existing setup|g" \
        -e "s|{{ARCHITECTURE_SECTION}}|<!-- TODO: Document your project's architecture here -->|g" \
        -e "s|{{TESTING_SECTION}}||g" \
        -e "s|{{TOOL_INSTALL_INSTRUCTIONS}}|<!-- TODO: Add project-specific tool install steps -->|g" \
        -e "s|{{EXTRA_BREW_PACKAGES}}||g" \
        -e "s|{{EXTRA_WINGET_PACKAGES}}||g" \
        -e "s|{{MCP_CONFIG}}|<!-- TODO: Add MCP server configs if needed -->|g" \
        "$src" > "$dest"
}

ask_action() {
    local component="$1"
    local has_existing="$2"  # true/false
    local default_action="$3"  # m/s/r

    if [[ "$has_existing" == "true" ]]; then
        read -rp "  ${component} (exists) — [m]erge/[s]kip/[r]eplace [${default_action}]: " action
        action="${action:-$default_action}"
    else
        read -rp "  ${component} (missing) — [a]dd/[s]kip [a]: " action
        action="${action:-a}"
        [[ "$action" == "a" ]] && action="r"  # treat "add" as "replace" (creates new)
    fi
    echo "$action"
}

BASELINE="$KIT_ROOT/templates/baseline"

# --- CLAUDE.md ---
action=$(ask_action "CLAUDE.md" "${EXISTING[CLAUDE.md]}" "s")
case "$action" in
    r) render_template "$BASELINE/CLAUDE.md.tmpl" "$TARGET_DIR/CLAUDE.md"; ok "CLAUDE.md replaced" ;;
    m)
        # Append kit sections that are missing from existing CLAUDE.md
        if [[ -f "$TARGET_DIR/CLAUDE.md" ]]; then
            # Check which key sections exist
            missing_sections=""
            for section in "Investigation-First" "Anti-Spiral" "Git Safety" "Phase Gates" "Session Start" "Session Workflow" "Milestone Reporting"; do
                if ! grep -qi "$section" "$TARGET_DIR/CLAUDE.md" 2>/dev/null; then
                    missing_sections="$missing_sections $section"
                fi
            done
            if [[ -n "$missing_sections" ]]; then
                echo ""
                echo "    Your CLAUDE.md is missing these kit sections:$missing_sections"
                echo "    Kit CLAUDE.md template has been written to: CLAUDE.md.kit-reference"
                echo "    Merge manually — your existing CLAUDE.md is preserved."
                render_template "$BASELINE/CLAUDE.md.tmpl" "$TARGET_DIR/CLAUDE.md.kit-reference"
                ok "CLAUDE.md preserved, kit reference written to CLAUDE.md.kit-reference"
            else
                ok "CLAUDE.md already has all key sections"
            fi
        fi
        ;;
    *) skip "CLAUDE.md (kept as-is)" ;;
esac

# --- PROJECT_STATE.md ---
action=$(ask_action "PROJECT_STATE.md" "${EXISTING[PROJECT_STATE.md]}" "s")
case "$action" in
    r) render_template "$BASELINE/PROJECT_STATE.md.tmpl" "$TARGET_DIR/PROJECT_STATE.md"; ok "PROJECT_STATE.md created" ;;
    *) skip "PROJECT_STATE.md" ;;
esac

# --- REFERENCE_MAP.md ---
action=$(ask_action "REFERENCE_MAP.md" "${EXISTING[REFERENCE_MAP.md]}" "s")
case "$action" in
    r) render_template "$BASELINE/REFERENCE_MAP.md.tmpl" "$TARGET_DIR/REFERENCE_MAP.md"; ok "REFERENCE_MAP.md created" ;;
    *) skip "REFERENCE_MAP.md" ;;
esac

# --- .claude/MEMORY.md ---
action=$(ask_action ".claude/MEMORY.md" "${EXISTING[.claude/MEMORY.md]}" "s")
case "$action" in
    r) mkdir -p "$TARGET_DIR/.claude"; render_template "$BASELINE/claude/MEMORY.md.tmpl" "$TARGET_DIR/.claude/MEMORY.md"; ok ".claude/MEMORY.md created" ;;
    *) skip ".claude/MEMORY.md" ;;
esac

# --- Rules (always merge — add missing baseline rules without overwriting existing) ---
header "  Rules"
mkdir -p "$TARGET_DIR/.claude/rules"
rules_added=0
rules_skipped=0
for rule_file in "$BASELINE/claude/rules/"*.md; do
    rule_name=$(basename "$rule_file")
    if [[ -f "$TARGET_DIR/.claude/rules/$rule_name" ]]; then
        skip "  $rule_name (exists, keeping yours)"
        rules_skipped=$((rules_skipped + 1))
    else
        cp "$rule_file" "$TARGET_DIR/.claude/rules/$rule_name"
        ok "  $rule_name (added)"
        rules_added=$((rules_added + 1))
    fi
done

# Stack-specific rules
STACK_DIR="$KIT_ROOT/templates/stack-presets"
if [[ -d "$STACK_DIR/$PRIMARY_STACK/rules" ]]; then
    for rule_file in "$STACK_DIR/$PRIMARY_STACK/rules/"*.md; do
        rule_name=$(basename "$rule_file")
        if [[ ! -f "$TARGET_DIR/.claude/rules/$rule_name" ]]; then
            cp "$rule_file" "$TARGET_DIR/.claude/rules/$rule_name"
            ok "  $rule_name (${PRIMARY_STACK} preset, added)"
            rules_added=$((rules_added + 1))
        fi
    done
fi
echo "  Rules: $rules_added added, $rules_skipped kept existing"

# --- Setup templates (add if missing) ---
action=$(ask_action ".claude/setup/" "${EXISTING[.claude/setup]}" "m")
case "$action" in
    r|m)
        mkdir -p "$TARGET_DIR/.claude/setup"
        for platform in macos windows cloud; do
            if [[ ! -f "$TARGET_DIR/.claude/setup/${platform}.md" ]]; then
                render_template "$BASELINE/claude/setup/${platform}.md.tmpl" "$TARGET_DIR/.claude/setup/${platform}.md"
                ok "  .claude/setup/${platform}.md (added)"
            else
                skip "  .claude/setup/${platform}.md (exists)"
            fi
        done
        ;;
    *) skip ".claude/setup/" ;;
esac

# --- Handoff skill (add if missing) ---
action=$(ask_action ".claude/skills/handoff/" "${EXISTING[.claude/skills]}" "m")
case "$action" in
    r|m)
        if [[ ! -f "$TARGET_DIR/.claude/skills/handoff/SKILL.md" ]]; then
            mkdir -p "$TARGET_DIR/.claude/skills/handoff"
            render_template "$BASELINE/claude/skills/handoff/SKILL.md.tmpl" "$TARGET_DIR/.claude/skills/handoff/SKILL.md"
            ok "  .claude/skills/handoff/SKILL.md (added)"
        else
            skip "  .claude/skills/handoff/SKILL.md (exists)"
        fi
        ;;
    *) skip ".claude/skills/handoff/" ;;
esac

# --- Pre-commit hook ---
action=$(ask_action ".githooks/pre-commit" "${EXISTING[.githooks/pre-commit]}" "s")
case "$action" in
    r)
        mkdir -p "$TARGET_DIR/.githooks"
        render_template "$BASELINE/githooks/pre-commit.tmpl" "$TARGET_DIR/.githooks/pre-commit"
        chmod +x "$TARGET_DIR/.githooks/pre-commit"
        ok ".githooks/pre-commit created"
        ;;
    m)
        mkdir -p "$TARGET_DIR/.githooks"
        if [[ -f "$TARGET_DIR/.githooks/pre-commit" ]]; then
            render_template "$BASELINE/githooks/pre-commit.tmpl" "$TARGET_DIR/.githooks/pre-commit.kit-reference"
            ok ".githooks/pre-commit preserved, kit version at .kit-reference"
        fi
        ;;
    *) skip ".githooks/pre-commit" ;;
esac

# --- Scripts ---
header "  Scripts"
mkdir -p "$TARGET_DIR/scripts"

if [[ ! -f "$TARGET_DIR/scripts/sync-memory.sh" ]]; then
    cp "$BASELINE/scripts/sync-memory.sh" "$TARGET_DIR/scripts/sync-memory.sh"
    chmod +x "$TARGET_DIR/scripts/sync-memory.sh"
    ok "  scripts/sync-memory.sh (added)"
else
    skip "  scripts/sync-memory.sh (exists)"
fi

if [[ ! -f "$TARGET_DIR/scripts/verify-sync.sh" ]]; then
    render_template "$BASELINE/scripts/verify-sync.sh.tmpl" "$TARGET_DIR/scripts/verify-sync.sh"
    chmod +x "$TARGET_DIR/scripts/verify-sync.sh"
    ok "  scripts/verify-sync.sh (added)"
else
    skip "  scripts/verify-sync.sh (exists)"
fi

# --- Workflow feedback rule (empty accumulator, only if missing) ---
if [[ ! -f "$TARGET_DIR/.claude/rules/workflow-feedback.md" ]]; then
    cat > "$TARGET_DIR/.claude/rules/workflow-feedback.md" <<'RULE'
## Workflow Feedback (Learned Rules)

<!-- This file accumulates project-specific workflow lessons.
     Add entries here when the user corrects your approach or
     confirms a non-obvious pattern worked well. -->
RULE
    ok "  .claude/rules/workflow-feedback.md (empty accumulator added)"
fi

# ---------------------------------------------------------------------------
# Phase 5: Git configuration
# ---------------------------------------------------------------------------
header "Git Configuration"

if [[ "$(git config core.hooksPath 2>/dev/null)" != ".githooks" ]]; then
    git -C "$TARGET_DIR" config core.hooksPath .githooks
    ok "core.hooksPath set to .githooks"
else
    ok "core.hooksPath already .githooks"
fi

# Append to .gitignore
GITIGNORE="$TARGET_DIR/.gitignore"
touch "$GITIGNORE"
declare -a IGNORE_ENTRIES=(".claude/worktrees/" ".claude/settings.local.json")
for entry in "${IGNORE_ENTRIES[@]}"; do
    if ! grep -qF "$entry" "$GITIGNORE" 2>/dev/null; then
        echo "$entry" >> "$GITIGNORE"
    fi
done
ok ".gitignore updated"

# Create memory-sync dir
mkdir -p "$TARGET_DIR/.claude/memory-sync"

# ---------------------------------------------------------------------------
# Phase 6: Generate manifest
# ---------------------------------------------------------------------------
header "Generating Manifest"

# Detect existing features
HAS_BACKLOG=false; [[ -f "$TARGET_DIR/backlog.json" ]] && HAS_BACKLOG=true
HAS_DOMAINS=false; [[ -f "$TARGET_DIR/DOMAINS.md" ]] && HAS_DOMAINS=true
HAS_TESTING=false; [[ -f "$TARGET_DIR/.claude/rules/testing-requirements.md" ]] && HAS_TESTING=true

# Detect agents
AGENTS_JSON="[]"
if [[ -d "$TARGET_DIR/.claude/agents" ]]; then
    for agent_dir in "$TARGET_DIR/.claude/agents"/*/; do
        agent_name=$(basename "$agent_dir")
        if [[ "$AGENTS_JSON" == "[]" ]]; then
            AGENTS_JSON="[\"$agent_name\"]"
        else
            AGENTS_JSON=$(echo "$AGENTS_JSON" | sed "s/\]/,\"$agent_name\"]/")
        fi
    done
fi

# Detect skills
SKILLS_JSON='["handoff"]'
if [[ -d "$TARGET_DIR/.claude/skills" ]]; then
    for skill_item in "$TARGET_DIR/.claude/skills"/*/; do
        skill_name=$(basename "$skill_item")
        [[ "$skill_name" == "handoff" ]] && continue
        SKILLS_JSON=$(echo "$SKILLS_JSON" | sed "s/\]/,\"$skill_name\"]/")
    done
fi

cat > "$TARGET_DIR/claude-ops.json" <<MANIFEST
{
  "version": "${VERSION}",
  "kitRepo": "saddestmartian/claude-ops-kit",
  "adoptedFrom": "existing",
  "project": {
    "name": "${PROJECT_NAME}",
    "repo": "${GITHUB_ORG}/${PROJECT_NAME}",
    "stack": ["${PRIMARY_STACK}"],
    "taskPrefix": "${TASK_PREFIX}",
    "sourceDir": "${SOURCE_DIR}",
    "fileExtension": "${FILE_EXTENSION}"
  },
  "tools": {
    "lint": "${LINT_CMD}",
    "format": "${FORMAT_CMD}",
    "test": "${TEST_CMD}"
  },
  "features": {
    "backlog": ${HAS_BACKLOG},
    "domains": ${HAS_DOMAINS},
    "agents": ${AGENTS_JSON},
    "skills": ${SKILLS_JSON},
    "testing": ${HAS_TESTING}
  },
  "lastUpgrade": "${TODAY}"
}
MANIFEST
ok "claude-ops.json (manifest created)"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
header "Adoption Complete!"
echo ""
echo "  ${PROJECT_NAME} is now managed by claude-ops-kit v${VERSION}"
echo ""
echo "  What happened:"
echo "    • Scanned existing setup ($found_count items found)"
echo "    • Added $rules_added missing baseline rules (kept $rules_skipped existing)"
echo "    • Created missing infrastructure (setup, scripts, hooks)"
echo "    • Generated claude-ops.json manifest"
echo ""
if [[ -f "$TARGET_DIR/CLAUDE.md.kit-reference" ]]; then
    echo "  ${YELLOW}Action needed:${RESET}"
    echo "    CLAUDE.md.kit-reference contains the kit's template."
    echo "    Compare with your CLAUDE.md and merge any missing sections."
    echo "    Delete CLAUDE.md.kit-reference when done."
    echo ""
fi
echo "  Next steps:"
echo "    1. Review any .kit-reference files and merge useful sections"
echo "    2. Run 'claude-ops status' to verify setup"
echo "    3. Future updates via 'claude-ops upgrade'"
echo ""
