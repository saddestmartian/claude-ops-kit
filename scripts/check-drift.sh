#!/bin/bash
# check-drift.sh — Compare installed .claude/rules/ against template source
# Designed for repos where the kit IS the template source (self-hosting).
# Reports mismatches, respects acknowledged divergences in drift-log.json.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

INSTALLED_DIR="$PROJECT_ROOT/.claude/rules"
TEMPLATE_DIR="$PROJECT_ROOT/templates/baseline/claude/rules"
DRIFT_LOG="$PROJECT_ROOT/.claude/drift-log.json"

# Colors
YELLOW="\033[0;33m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
DIM="\033[2m"
BOLD="\033[1m"
RESET="\033[0m"

if [[ ! -d "$INSTALLED_DIR" ]]; then
    echo "No .claude/rules/ directory — nothing to check."
    exit 0
fi

if [[ ! -d "$TEMPLATE_DIR" ]]; then
    echo "No templates/baseline/claude/rules/ — not a kit source repo."
    exit 0
fi

# Load acknowledged divergences from drift-log
declare -A ACKNOWLEDGED
if [[ -f "$DRIFT_LOG" ]] && command -v jq &>/dev/null; then
    while IFS= read -r name; do
        ACKNOWLEDGED["$name"]=true
    done < <(jq -r '.acknowledged[]?.rule // empty' "$DRIFT_LOG" 2>/dev/null)
fi

drifted=0
stale=0
missing_from_installed=0
extra_in_installed=0

# Check each template rule against installed copy
for template_file in "$TEMPLATE_DIR"/*.md; do
    rule_name=$(basename "$template_file")
    installed_file="$INSTALLED_DIR/$rule_name"

    if [[ ! -f "$installed_file" ]]; then
        # Template exists but not installed
        if [[ -z "${ACKNOWLEDGED[$rule_name]+x}" ]]; then
            printf "${YELLOW}  + missing:${RESET} %s — exists in templates but not installed\n" "$rule_name"
            missing_from_installed=$((missing_from_installed + 1))
        fi
        continue
    fi

    # Both exist — compare
    if ! diff -q "$template_file" "$installed_file" &>/dev/null; then
        if [[ -n "${ACKNOWLEDGED[$rule_name]+x}" ]]; then
            # Intentional divergence, skip
            continue
        fi

        # Determine which is newer
        template_mtime=$(stat -c %Y "$template_file" 2>/dev/null || stat -f %m "$template_file" 2>/dev/null || echo 0)
        installed_mtime=$(stat -c %Y "$installed_file" 2>/dev/null || stat -f %m "$installed_file" 2>/dev/null || echo 0)

        if [[ "$template_mtime" -gt "$installed_mtime" ]]; then
            printf "${YELLOW}  ~ stale:${RESET}   %s — template updated, installed copy is older\n" "$rule_name"
            stale=$((stale + 1))
        else
            printf "${CYAN}  ~ drifted:${RESET} %s — installed copy differs from template\n" "$rule_name"
            drifted=$((drifted + 1))
        fi
    fi
done

# Check for installed rules not in templates (custom or removed)
for installed_file in "$INSTALLED_DIR"/*.md; do
    rule_name=$(basename "$installed_file")
    template_file="$TEMPLATE_DIR/$rule_name"

    if [[ ! -f "$template_file" ]]; then
        # Only flag if not a known accumulator or custom rule
        case "$rule_name" in
            workflow-feedback.md|known-traps.md|override-protocol.md) continue ;;
        esac
        if [[ -z "${ACKNOWLEDGED[$rule_name]+x}" ]]; then
            printf "${DIM}  ? extra:${RESET}   %s — installed but not in templates\n" "$rule_name"
            extra_in_installed=$((extra_in_installed + 1))
        fi
    fi
done

total=$((drifted + stale + missing_from_installed + extra_in_installed))

if [[ $total -eq 0 ]]; then
    printf "${GREEN}  Rules in sync with templates.${RESET}\n"
else
    echo ""
    printf "${BOLD}  Drift summary:${RESET} %d drifted, %d stale, %d missing, %d extra\n" \
        "$drifted" "$stale" "$missing_from_installed" "$extra_in_installed"
    printf "  Run ${CYAN}/claude-ops-kit${RESET} to review and sync, or acknowledge in .claude/drift-log.json\n"
fi

exit 0
