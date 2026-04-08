#!/bin/bash
# init.sh — Bootstrap a project with Claude Code workflow from claude-ops-kit
set -euo pipefail

KIT_ROOT="${1:?Usage: init.sh <kit-root>}"
shift

VERSION="1.0.0"
TARGET_DIR="$(pwd)"

# Colors
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
BOLD="\033[1m"
RESET="\033[0m"

info()  { printf "${CYAN}→ %s${RESET}\n" "$1"; }
ok()    { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
warn()  { printf "${YELLOW}⚠ %s${RESET}\n" "$1"; }
header() { printf "\n${BOLD}%s${RESET}\n" "$1"; }

# ---------------------------------------------------------------------------
# Phase 1: Detection
# ---------------------------------------------------------------------------
FORCE=false
NO_DISCOVER=false
for arg in "$@"; do
    case "$arg" in
        --overwrite) FORCE=true ;;
        --no-discover) NO_DISCOVER=true ;;
    esac
done

# Shared discovery library
source "$KIT_ROOT/scripts/lib/discovery.sh"

header "claude-ops init v${VERSION}"

if [[ -f "$TARGET_DIR/claude-ops.json" ]]; then
    echo "This project is already initialized (claude-ops.json exists)."
    echo "Use 'claude-ops upgrade' to update templates."
    exit 1
fi

# Block if existing Claude Code content is detected (use adopt instead)
if [[ "$FORCE" != true ]]; then
    existing_found=()
    [[ -f "$TARGET_DIR/CLAUDE.md" ]] && existing_found+=("CLAUDE.md")
    [[ -d "$TARGET_DIR/.claude/rules" ]] && existing_found+=(".claude/rules/")
    [[ -f "$TARGET_DIR/.claude/MEMORY.md" ]] && existing_found+=(".claude/MEMORY.md")
    [[ -d "$TARGET_DIR/.claude/skills" ]] && existing_found+=(".claude/skills/")
    [[ -d "$TARGET_DIR/.claude/agents" ]] && existing_found+=(".claude/agents/")
    [[ -f "$TARGET_DIR/PROJECT_STATE.md" ]] && existing_found+=("PROJECT_STATE.md")

    if [[ ${#existing_found[@]} -gt 0 ]]; then
        printf "${RED}✖ Existing Claude Code setup detected:${RESET}\n"
        for item in "${existing_found[@]}"; do
            printf "    • %s\n" "$item"
        done
        echo ""
        echo "  init is designed for new projects. It will overwrite existing files."
        echo ""
        echo "  Use one of:"
        printf "    ${CYAN}claude-ops adopt${RESET}        Integrate kit into existing setup (recommended)\n"
        printf "    ${CYAN}claude-ops init --overwrite${RESET}  Force init, replacing existing files\n"
        exit 1
    fi
fi

if [[ ! -d "$TARGET_DIR/.git" ]]; then
    read -rp "No git repo found. Initialize one? [Y/n] " INIT_GIT
    if [[ "${INIT_GIT:-Y}" =~ ^[Yy] ]]; then
        git init "$TARGET_DIR"
    else
        echo "Git repo required. Aborting."
        exit 1
    fi
fi

# ---------------------------------------------------------------------------
# Phase 2: Configuration (interactive prompts)
# ---------------------------------------------------------------------------
header "Project Configuration"

# Project name
DEFAULT_NAME=$(basename "$TARGET_DIR")
read -rp "Project name [${DEFAULT_NAME}]: " PROJECT_NAME
PROJECT_NAME="${PROJECT_NAME:-$DEFAULT_NAME}"

# Task prefix
DEFAULT_PREFIX=$(echo "$PROJECT_NAME" | tr '[:lower:]' '[:upper:]' | cut -c1-3)
read -rp "Task ID prefix [${DEFAULT_PREFIX}]: " TASK_PREFIX
TASK_PREFIX="${TASK_PREFIX:-$DEFAULT_PREFIX}"

# Project description
read -rp "One-line project description: " PROJECT_DESCRIPTION
PROJECT_DESCRIPTION="${PROJECT_DESCRIPTION:-A project managed with claude-ops-kit}"

# Tech stack
echo ""
echo "Tech stacks (comma-separated):"
echo "  nodejs, typescript, swift, python, luau, other"
read -rp "Stack [nodejs]: " TECH_STACK
TECH_STACK="${TECH_STACK:-nodejs}"

# GitHub org
GITHUB_ORG=""
if git remote get-url origin &>/dev/null; then
    GITHUB_ORG=$(git remote get-url origin | sed -E 's#.*[:/]([^/]+)/[^/]+\.git$#\1#' 2>/dev/null || echo "")
fi
read -rp "GitHub org/user [${GITHUB_ORG:-your-org}]: " INPUT_ORG
GITHUB_ORG="${INPUT_ORG:-${GITHUB_ORG:-your-org}}"

# Source directory
read -rp "Source directory [src/]: " SOURCE_DIR
SOURCE_DIR="${SOURCE_DIR:-src/}"

# File extension (auto-detect from stack)
case "$TECH_STACK" in
    *typescript*) DEFAULT_EXT=".ts" ;;
    *swift*)      DEFAULT_EXT=".swift" ;;
    *python*)     DEFAULT_EXT=".py" ;;
    *luau*)       DEFAULT_EXT=".luau" ;;
    *)            DEFAULT_EXT=".js" ;;
esac
read -rp "Primary file extension [${DEFAULT_EXT}]: " FILE_EXTENSION
FILE_EXTENSION="${FILE_EXTENSION:-$DEFAULT_EXT}"

# Lint and format commands (auto-suggest from stack)
case "$TECH_STACK" in
    *typescript*|*nodejs*)
        DEFAULT_LINT="npx eslint ."
        DEFAULT_FORMAT="npx prettier --check ."
        DEFAULT_TEST="npm test"
        ;;
    *swift*)
        DEFAULT_LINT="swiftlint"
        DEFAULT_FORMAT="swiftformat --lint ."
        DEFAULT_TEST="swift test"
        ;;
    *python*)
        DEFAULT_LINT="ruff check ."
        DEFAULT_FORMAT="ruff format --check ."
        DEFAULT_TEST="pytest"
        ;;
    *luau*)
        DEFAULT_LINT="selene src/"
        DEFAULT_FORMAT="stylua --check src/"
        DEFAULT_TEST="echo 'Tests run via Roblox Studio playtest'"
        ;;
    *)
        DEFAULT_LINT="echo 'No lint configured'"
        DEFAULT_FORMAT="echo 'No formatter configured'"
        DEFAULT_TEST="echo 'No tests configured'"
        ;;
esac

read -rp "Lint command [${DEFAULT_LINT}]: " LINT_CMD
LINT_CMD="${LINT_CMD:-$DEFAULT_LINT}"

read -rp "Format command [${DEFAULT_FORMAT}]: " FORMAT_CMD
FORMAT_CMD="${FORMAT_CMD:-$DEFAULT_FORMAT}"

read -rp "Test command [${DEFAULT_TEST}]: " TEST_CMD
TEST_CMD="${TEST_CMD:-$DEFAULT_TEST}"

# ---------------------------------------------------------------------------
# Phase 3: Optional modules
# ---------------------------------------------------------------------------
header "Optional Modules"
echo "Select optional modules to include (y/N for each):"

ask_module() {
    local desc="$1"
    read -rp "  Include ${desc}? [y/N] " answer
    [[ "${answer:-N}" =~ ^[Yy] ]]
}

OPT_BACKLOG=false
OPT_DOMAINS=false
OPT_ARCH_VALIDATOR=false
OPT_DESIGN_ADVISOR=false
OPT_DESIGN_AUDITOR=false
OPT_CODE_REVIEWER=false
OPT_PR_SKILL=false
OPT_VIDEO_TOOLKIT=false
OPT_TESTING=false
OPT_PRE_IMPL_CHECK=false
OPT_DEP_GRAPH=false
OPT_AUDIT=false
OPT_RETRO=false

ask_module "Backlog system (JSON + kanban viewer)" && OPT_BACKLOG=true
ask_module "Domain model (DDD bounded contexts)" && OPT_DOMAINS=true
ask_module "Architecture validator agent" && OPT_ARCH_VALIDATOR=true
ask_module "Design advisor agent" && OPT_DESIGN_ADVISOR=true
ask_module "Design auditor agent (compliance scanner)" && OPT_DESIGN_AUDITOR=true
ask_module "Code reviewer agent" && OPT_CODE_REVIEWER=true
ask_module "PR skill (lint/test gates before PR)" && OPT_PR_SKILL=true
ask_module "Video toolkit (FFmpeg + Whisper)" && OPT_VIDEO_TOOLKIT=true
ask_module "Testing framework (decision tree + coverage)" && OPT_TESTING=true
ask_module "Pre-implementation checklist (read-before-write gate)" && OPT_PRE_IMPL_CHECK=true
ask_module "Dependency graph generator" && OPT_DEP_GRAPH=true
ask_module "Codebase audit protocol" && OPT_AUDIT=true
ask_module "Retrospective template" && OPT_RETRO=true

# ---------------------------------------------------------------------------
# Phase 4: File Generation
# ---------------------------------------------------------------------------
header "Generating Files"

TODAY=$(date +%Y-%m-%d)

# Template substitution function
render_template() {
    local src="$1"
    local dest="$2"
    sed -e "s|{{PROJECT_NAME}}|${PROJECT_NAME}|g" \
        -e "s|{{PROJECT_DESCRIPTION}}|${PROJECT_DESCRIPTION}|g" \
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
        -e "s|{{ACTIVE_PHASE}}|Getting started|g" \
        -e "s|{{ARCHITECTURE_SECTION}}|<!-- TODO: Document your project's architecture here -->|g" \
        -e "s|{{TESTING_SECTION}}||g" \
        -e "s|{{TOOL_INSTALL_INSTRUCTIONS}}|<!-- TODO: Add project-specific tool install steps -->|g" \
        -e "s|{{EXTRA_BREW_PACKAGES}}||g" \
        -e "s|{{EXTRA_WINGET_PACKAGES}}||g" \
        -e "s|{{MCP_CONFIG}}|<!-- TODO: Add MCP server configs if needed -->|g" \
        "$src" > "$dest"
}

# Create directories
mkdir -p "$TARGET_DIR/.claude/rules"
mkdir -p "$TARGET_DIR/.claude/skills/handoff"
mkdir -p "$TARGET_DIR/.claude/setup"
mkdir -p "$TARGET_DIR/.claude/memory-sync"
mkdir -p "$TARGET_DIR/.githooks"
mkdir -p "$TARGET_DIR/scripts"

# Baseline templates
BASELINE="$KIT_ROOT/templates/baseline"

render_template "$BASELINE/CLAUDE.md.tmpl" "$TARGET_DIR/CLAUDE.md"
info "CLAUDE.md"

render_template "$BASELINE/PROJECT_STATE.md.tmpl" "$TARGET_DIR/PROJECT_STATE.md"
info "PROJECT_STATE.md"

render_template "$BASELINE/REFERENCE_MAP.md.tmpl" "$TARGET_DIR/REFERENCE_MAP.md"
info "REFERENCE_MAP.md"

render_template "$BASELINE/claude/MEMORY.md.tmpl" "$TARGET_DIR/.claude/MEMORY.md"
info ".claude/MEMORY.md"

# Rules (copy verbatim — no template variables)
cp "$BASELINE/claude/rules/"*.md "$TARGET_DIR/.claude/rules/"
info ".claude/rules/ (7 baseline rules)"

# Stack-specific rules
STACK_DIR="$KIT_ROOT/templates/stack-presets"
PRIMARY_STACK=$(echo "$TECH_STACK" | cut -d',' -f1 | tr -d ' ')
if [[ -d "$STACK_DIR/$PRIMARY_STACK/rules" ]]; then
    cp "$STACK_DIR/$PRIMARY_STACK/rules/"*.md "$TARGET_DIR/.claude/rules/" 2>/dev/null || true
    info ".claude/rules/ (${PRIMARY_STACK} stack rules)"
fi

# Setup templates
for platform in macos windows cloud; do
    render_template "$BASELINE/claude/setup/${platform}.md.tmpl" "$TARGET_DIR/.claude/setup/${platform}.md"
done
info ".claude/setup/ (3 platforms)"

# Handoff skill
render_template "$BASELINE/claude/skills/handoff/SKILL.md.tmpl" "$TARGET_DIR/.claude/skills/handoff/SKILL.md"
info ".claude/skills/handoff/"

# Pre-commit hook
render_template "$BASELINE/githooks/pre-commit.tmpl" "$TARGET_DIR/.githooks/pre-commit"
chmod +x "$TARGET_DIR/.githooks/pre-commit"
info ".githooks/pre-commit"

# Scripts
cp "$BASELINE/scripts/sync-memory.sh" "$TARGET_DIR/scripts/sync-memory.sh"
chmod +x "$TARGET_DIR/scripts/sync-memory.sh"
render_template "$BASELINE/scripts/verify-sync.sh.tmpl" "$TARGET_DIR/scripts/verify-sync.sh"
chmod +x "$TARGET_DIR/scripts/verify-sync.sh"
info "scripts/ (sync-memory.sh, verify-sync.sh)"

# Empty workflow-feedback rule
cat > "$TARGET_DIR/.claude/rules/workflow-feedback.md" <<'RULE'
## Workflow Feedback (Learned Rules)

<!-- This file accumulates project-specific workflow lessons.
     Add entries here when the user corrects your approach or
     confirms a non-obvious pattern worked well. -->
RULE
info ".claude/rules/workflow-feedback.md (empty accumulator)"

# Known-traps accumulator
cp "$BASELINE/claude/rules/known-traps.md" "$TARGET_DIR/.claude/rules/known-traps.md"
info ".claude/rules/known-traps.md (empty accumulator)"

# ---------------------------------------------------------------------------
# Phase 5: Optional modules
# ---------------------------------------------------------------------------

OPTIONAL="$KIT_ROOT/templates/optional"

if $OPT_BACKLOG; then
    render_template "$OPTIONAL/backlog/backlog.json.tmpl" "$TARGET_DIR/backlog.json" 2>/dev/null || \
        cp "$OPTIONAL/backlog/backlog.json.tmpl" "$TARGET_DIR/backlog.json"
    cp "$OPTIONAL/backlog/backlog-viewer.html" "$TARGET_DIR/backlog-viewer.html" 2>/dev/null || true
    info "backlog.json + backlog-viewer.html"
fi

if $OPT_DOMAINS; then
    render_template "$OPTIONAL/domains/DOMAINS.md.tmpl" "$TARGET_DIR/DOMAINS.md" 2>/dev/null || \
        cp "$OPTIONAL/domains/DOMAINS.md.tmpl" "$TARGET_DIR/DOMAINS.md"
    info "DOMAINS.md"
fi

if $OPT_ARCH_VALIDATOR; then
    mkdir -p "$TARGET_DIR/.claude/agents/architecture-validator"
    render_template "$OPTIONAL/agents/architecture-validator/CLAUDE.md.tmpl" \
        "$TARGET_DIR/.claude/agents/architecture-validator/CLAUDE.md" 2>/dev/null || \
        cp "$OPTIONAL/agents/architecture-validator/CLAUDE.md.tmpl" \
           "$TARGET_DIR/.claude/agents/architecture-validator/CLAUDE.md"
    info ".claude/agents/architecture-validator/"
fi

if $OPT_DESIGN_ADVISOR; then
    mkdir -p "$TARGET_DIR/.claude/agents/design-advisor"
    render_template "$OPTIONAL/agents/design-advisor/CLAUDE.md.tmpl" \
        "$TARGET_DIR/.claude/agents/design-advisor/CLAUDE.md" 2>/dev/null || \
        cp "$OPTIONAL/agents/design-advisor/CLAUDE.md.tmpl" \
           "$TARGET_DIR/.claude/agents/design-advisor/CLAUDE.md"
    info ".claude/agents/design-advisor/"
fi

if $OPT_DESIGN_AUDITOR; then
    mkdir -p "$TARGET_DIR/.claude/agents/design-auditor"
    render_template "$OPTIONAL/agents/design-auditor/CLAUDE.md.tmpl" \
        "$TARGET_DIR/.claude/agents/design-auditor/CLAUDE.md" 2>/dev/null || \
        cp "$OPTIONAL/agents/design-auditor/CLAUDE.md.tmpl" \
           "$TARGET_DIR/.claude/agents/design-auditor/CLAUDE.md"
    info ".claude/agents/design-auditor/"
fi

if $OPT_CODE_REVIEWER; then
    mkdir -p "$TARGET_DIR/.claude/agents/code-reviewer"
    render_template "$OPTIONAL/agents/code-reviewer/CLAUDE.md.tmpl" \
        "$TARGET_DIR/.claude/agents/code-reviewer/CLAUDE.md" 2>/dev/null || \
        cp "$OPTIONAL/agents/code-reviewer/CLAUDE.md.tmpl" \
           "$TARGET_DIR/.claude/agents/code-reviewer/CLAUDE.md"
    info ".claude/agents/code-reviewer/"
fi

if $OPT_PR_SKILL; then
    mkdir -p "$TARGET_DIR/.claude/skills/pr"
    render_template "$OPTIONAL/skills/pr/SKILL.md.tmpl" \
        "$TARGET_DIR/.claude/skills/pr/SKILL.md" 2>/dev/null || \
        cp "$OPTIONAL/skills/pr/SKILL.md.tmpl" "$TARGET_DIR/.claude/skills/pr/SKILL.md"
    info ".claude/skills/pr/"
fi

if $OPT_VIDEO_TOOLKIT; then
    mkdir -p "$TARGET_DIR/.claude/skills/video-toolkit/scripts"
    render_template "$OPTIONAL/skills/video-toolkit/SKILL.md.tmpl" \
        "$TARGET_DIR/.claude/skills/video-toolkit/SKILL.md" 2>/dev/null || \
        cp "$OPTIONAL/skills/video-toolkit/SKILL.md.tmpl" "$TARGET_DIR/.claude/skills/video-toolkit/SKILL.md"
    cp -r "$OPTIONAL/skills/video-toolkit/scripts/"* "$TARGET_DIR/.claude/skills/video-toolkit/scripts/" 2>/dev/null || true
    info ".claude/skills/video-toolkit/"
fi

if $OPT_TESTING; then
    render_template "$OPTIONAL/testing/testing-requirements.md.tmpl" \
        "$TARGET_DIR/.claude/rules/testing-requirements.md" 2>/dev/null || \
        cp "$OPTIONAL/testing/testing-requirements.md.tmpl" \
           "$TARGET_DIR/.claude/rules/testing-requirements.md"
    info ".claude/rules/testing-requirements.md"
fi

if $OPT_PRE_IMPL_CHECK; then
    cp "$OPTIONAL/testing/pre-implementation-checklist.md" "$TARGET_DIR/.claude/rules/pre-implementation-checklist.md" 2>/dev/null || true
    info ".claude/rules/pre-implementation-checklist.md"
fi

if $OPT_AUDIT; then
    cp "$OPTIONAL/codebase-audit/audit-protocol.md" "$TARGET_DIR/.claude/rules/audit-protocol.md" 2>/dev/null || true
    info ".claude/rules/audit-protocol.md"
fi

if $OPT_RETRO; then
    mkdir -p "$TARGET_DIR/.claude/retrospectives"
    cp "$OPTIONAL/retrospective/retro-template.md" "$TARGET_DIR/.claude/retrospectives/retro-template.md" 2>/dev/null || true
    info ".claude/retrospectives/retro-template.md"
fi

# ---------------------------------------------------------------------------
# Phase 5.5: Discover unknown .claude/ files (only meaningful with --overwrite)
# ---------------------------------------------------------------------------
run_discovery "$KIT_ROOT" "$TARGET_DIR" "$PROJECT_NAME" "$NO_DISCOVER"

# ---------------------------------------------------------------------------
# Phase 6: Git configuration
# ---------------------------------------------------------------------------
header "Git Configuration"

git -C "$TARGET_DIR" config core.hooksPath .githooks
ok "core.hooksPath set to .githooks"

# Append to .gitignore
GITIGNORE="$TARGET_DIR/.gitignore"
touch "$GITIGNORE"

declare -a IGNORE_ENTRIES=(".claude/worktrees/" ".env" "node_modules/" ".claude/settings.local.json")
for entry in "${IGNORE_ENTRIES[@]}"; do
    if ! grep -qF "$entry" "$GITIGNORE" 2>/dev/null; then
        echo "$entry" >> "$GITIGNORE"
    fi
done
ok ".gitignore updated"

# ---------------------------------------------------------------------------
# Phase 7: Generate manifest
# ---------------------------------------------------------------------------
header "Generating Manifest"

# Build features JSON
AGENTS_JSON="[]"
SKILLS_JSON='["handoff"]'
[[ $OPT_ARCH_VALIDATOR == true ]] && AGENTS_JSON=$(echo "$AGENTS_JSON" | sed 's/\]/,"architecture-validator"]/' | sed 's/\[,/[/')
[[ $OPT_DESIGN_ADVISOR == true ]] && AGENTS_JSON=$(echo "$AGENTS_JSON" | sed 's/\]/,"design-advisor"]/' | sed 's/\[,/[/')
[[ $OPT_DESIGN_AUDITOR == true ]] && AGENTS_JSON=$(echo "$AGENTS_JSON" | sed 's/\]/,"design-auditor"]/' | sed 's/\[,/[/')
[[ $OPT_CODE_REVIEWER == true ]] && AGENTS_JSON=$(echo "$AGENTS_JSON" | sed 's/\]/,"code-reviewer"]/' | sed 's/\[,/[/')
[[ $OPT_PR_SKILL == true ]] && SKILLS_JSON=$(echo "$SKILLS_JSON" | sed 's/\]/,"pr"]/')
[[ $OPT_VIDEO_TOOLKIT == true ]] && SKILLS_JSON=$(echo "$SKILLS_JSON" | sed 's/\]/,"video-toolkit"]/')

cat > "$TARGET_DIR/claude-ops.json" <<MANIFEST
{
  "version": "${VERSION}",
  "kitRepo": "saddestmartian/claude-ops-kit",
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
    "backlog": ${OPT_BACKLOG},
    "domains": ${OPT_DOMAINS},
    "agents": ${AGENTS_JSON},
    "skills": ${SKILLS_JSON},
    "testing": ${OPT_TESTING},
    "dependencyGraph": ${OPT_DEP_GRAPH},
    "retrospectives": ${OPT_RETRO}
  },
  "lastUpgrade": "${TODAY}"
}
MANIFEST
ok "claude-ops.json"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
header "Setup Complete!"
echo ""
echo "  claude-ops initialized for \"${PROJECT_NAME}\" (${PRIMARY_STACK})"
echo ""
echo "  Created:"
echo "    CLAUDE.md                      Root instructions"
echo "    PROJECT_STATE.md               Session context"
echo "    REFERENCE_MAP.md               Module inventory"
echo "    .claude/rules/                 $(ls -1 "$TARGET_DIR/.claude/rules/" | wc -l | tr -d ' ') rules"
echo "    .claude/skills/handoff/        Session handoff skill"
echo "    .claude/setup/                 3 platform checklists"
echo "    .githooks/pre-commit           Format + lint gates"
echo "    scripts/                       Memory sync + drift check"
echo "    claude-ops.json                Kit manifest (v${VERSION})"
$OPT_BACKLOG && echo "    backlog.json                   Task tracking"
$OPT_DOMAINS && echo "    DOMAINS.md                     DDD bounded contexts"
echo ""
echo "  Next steps:"
echo "    1. Review and customize CLAUDE.md (architecture section)"
echo "    2. Read .claude/setup/macos.md (or windows.md) for tool setup"
echo "    3. Start a Claude Code session and verify instructions load"
echo ""
