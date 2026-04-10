#!/bin/bash
# discovery.sh — Shared library for discovering unknown .claude/ files
# Sourced by init.sh, adopt.sh, and upgrade.sh
#
# Provides: build_known_paths, discover_unknown_files, prompt_disposition,
#           execute_dispositions, update_manifest_discovered, file_github_issue

# ---------------------------------------------------------------------------
# Known-paths registry
# ---------------------------------------------------------------------------
declare -gA KNOWN_PATHS=()
declare -ga UNKNOWN_ITEMS=()
declare -ga DISPOSITION_PATH=()
declare -ga DISPOSITION_ACTION=()

build_known_paths() {
    local kit_root="$1"
    local target_dir="$2"
    KNOWN_PATHS=()

    # --- A. Kit baseline (always present) ---
    local baseline_paths=(
        ".claude"
        ".claude/MEMORY.md"
        ".claude/memory-sync"
        ".claude/memory-sync/.sync-manifest"
        ".claude/rules"
        ".claude/rules/anti-spiral.md"
        ".claude/rules/code-discipline.md"
        ".claude/rules/confidence-flagging.md"
        ".claude/rules/git-safety.md"
        ".claude/rules/investigation-first.md"
        ".claude/rules/milestone-reporting.md"
        ".claude/rules/phase-gates.md"
        ".claude/rules/workflow-feedback.md"
        ".claude/rules/known-traps.md"
        ".claude/setup"
        ".claude/setup/macos.md"
        ".claude/setup/windows.md"
        ".claude/setup/cloud.md"
        ".claude/skills"
        ".claude/skills/handoff"
        ".claude/skills/handoff/SKILL.md"
        ".claude/skills/claude-ops-kit"
        ".claude/skills/claude-ops-kit/SKILL.md"
        ".claude/skills/claude-ops-kit/procedures"
        ".claude/skills/claude-ops-kit/procedures/assess.md"
        ".claude/skills/claude-ops-kit/procedures/init.md"
        ".claude/skills/claude-ops-kit/procedures/adopt.md"
        ".claude/skills/claude-ops-kit/procedures/upgrade.md"
        ".claude/skills/claude-ops-kit/procedures/evaluate.md"
        ".claude/skills/claude-ops-kit/procedures/contribute.md"
    )
    for p in "${baseline_paths[@]}"; do
        KNOWN_PATHS["$p"]="kit"
    done

    # --- B. Kit optional modules ---
    local optional_paths=(
        ".claude/rules/testing-requirements.md"
        ".claude/rules/pre-implementation-checklist.md"
        ".claude/rules/audit-protocol.md"
        ".claude/skills/pr"
        ".claude/skills/pr/SKILL.md"
        ".claude/skills/video-toolkit"
        ".claude/skills/video-toolkit/SKILL.md"
        ".claude/skills/video-toolkit/scripts"
        ".claude/skills/video-toolkit/references"
        ".claude/agents"
        ".claude/agents/architecture-validator"
        ".claude/agents/architecture-validator/CLAUDE.md"
        ".claude/agents/design-advisor"
        ".claude/agents/design-advisor/CLAUDE.md"
        ".claude/agents/design-auditor"
        ".claude/agents/design-auditor/CLAUDE.md"
        ".claude/agents/code-reviewer"
        ".claude/agents/code-reviewer/CLAUDE.md"
        ".claude/retrospectives"
        ".claude/retrospectives/retro-template.md"
    )
    for p in "${optional_paths[@]}"; do
        KNOWN_PATHS["$p"]="kit"
    done

    # --- C. Stack-specific rules (scan ALL presets to avoid false flags) ---
    if [[ -d "$kit_root/templates/stack-presets" ]]; then
        for rule_file in "$kit_root"/templates/stack-presets/*/rules/*.md; do
            if [[ -f "$rule_file" ]]; then
                local rule_name
                rule_name=$(basename "$rule_file")
                KNOWN_PATHS[".claude/rules/$rule_name"]="kit"
            fi
        done
    fi

    # --- D. Claude Code native + kit-managed settings (silently skipped) ---
    local native_paths=(
        ".claude/settings.json"
        ".claude/settings.local.json"
        ".claude/worktrees"
    )
    # Note: .claude/settings.json is now kit-managed (SessionStart hooks)
    # but kept in native_paths to avoid flagging as unknown
    for p in "${native_paths[@]}"; do
        KNOWN_PATHS["$p"]="native"
    done

    # --- E. Previously discovered items from manifest ---
    local manifest="$target_dir/claude-ops.json"
    if [[ -f "$manifest" ]] && command -v jq &>/dev/null; then
        local discovered_count
        discovered_count=$(jq -r '.discovered // [] | length' "$manifest" 2>/dev/null || echo "0")
        if [[ "$discovered_count" -gt 0 ]]; then
            local i
            for ((i = 0; i < discovered_count; i++)); do
                local dpath daction
                dpath=$(jq -r ".discovered[$i].path" "$manifest" 2>/dev/null)
                daction=$(jq -r ".discovered[$i].action" "$manifest" 2>/dev/null)
                # Re-prompt removed items if file reappeared; skip keep/ignore
                if [[ "$daction" == "keep" || "$daction" == "ignore" ]]; then
                    KNOWN_PATHS["$dpath"]="discovered"
                fi
            done
        fi
    fi
}

# ---------------------------------------------------------------------------
# Discovery
# ---------------------------------------------------------------------------
discover_unknown_files() {
    local target_dir="$1"
    UNKNOWN_ITEMS=()

    if [[ ! -d "$target_dir/.claude" ]]; then
        return 0
    fi

    # Collect all items under .claude/ (files and non-empty directories)
    local all_items=()
    while IFS= read -r item; do
        # Convert to relative path from project root
        local rel_path
        rel_path=$(echo "$item" | sed "s|^${target_dir}/||")
        all_items+=("$rel_path")
    done < <(find "$target_dir/.claude" -maxdepth 4 \( -type f -o -type d \) 2>/dev/null | sort)

    # First pass: identify unknown items
    local raw_unknowns=()
    for rel_path in "${all_items[@]}"; do
        # Skip if it's a known path
        if [[ -n "${KNOWN_PATHS[$rel_path]+x}" ]]; then
            continue
        fi

        # Skip if it's under a known native directory (worktrees/*)
        local skip=false
        for native in ".claude/worktrees" ".claude/memory-sync"; do
            if [[ "$rel_path" == "$native/"* ]]; then
                skip=true
                break
            fi
        done
        $skip && continue

        raw_unknowns+=("$rel_path")
    done

    # Second pass: collapse nested files under unknown parent directories
    # If .claude/skills/deploy/ is unknown, don't also list files inside it
    for item in "${raw_unknowns[@]}"; do
        local parent_is_unknown=false
        for other in "${raw_unknowns[@]}"; do
            if [[ "$item" != "$other" && "$item" == "$other/"* && -d "$target_dir/$other" ]]; then
                parent_is_unknown=true
                break
            fi
        done
        if ! $parent_is_unknown; then
            # Add trailing slash for directories
            if [[ -d "$target_dir/$item" ]]; then
                UNKNOWN_ITEMS+=("${item}/")
            else
                UNKNOWN_ITEMS+=("$item")
            fi
        fi
    done

    return 0
}

# ---------------------------------------------------------------------------
# Interactive disposition
# ---------------------------------------------------------------------------
prompt_disposition() {
    DISPOSITION_PATH=()
    DISPOSITION_ACTION=()

    local count=${#UNKNOWN_ITEMS[@]}
    local i=1

    for item in "${UNKNOWN_ITEMS[@]}"; do
        echo ""
        printf "  ${BOLD}%d.${RESET} %s\n" "$i" "$item"
        read -rp "     [r]emove  [k]eep (catalogue + file issue)  [i]gnore [k]: " action
        action="${action:-k}"

        case "$action" in
            r|R) action="remove" ;;
            k|K) action="keep" ;;
            i|I) action="ignore" ;;
            *)   action="keep" ;;
        esac

        DISPOSITION_PATH+=("$item")
        DISPOSITION_ACTION+=("$action")
        i=$((i + 1))
    done
}

# ---------------------------------------------------------------------------
# Execute dispositions
# ---------------------------------------------------------------------------
execute_dispositions() {
    local target_dir="$1"
    local project_name="${2:-unknown-project}"

    local kept=0 ignored=0 removed=0

    for ((i = 0; i < ${#DISPOSITION_PATH[@]}; i++)); do
        local path="${DISPOSITION_PATH[$i]}"
        local action="${DISPOSITION_ACTION[$i]}"
        # Strip trailing slash for filesystem operations
        local clean_path="${path%/}"

        case "$action" in
            remove)
                rm -rf "$target_dir/$clean_path"
                ok "Removed $path"
                removed=$((removed + 1))
                ;;
            keep)
                local issue_url=""
                issue_url=$(file_github_issue "$path" "$project_name")
                update_manifest_discovered "$target_dir" "$path" "keep" "$issue_url"
                ok "Catalogued $path (kept, issue filed)"
                kept=$((kept + 1))
                ;;
            ignore)
                update_manifest_discovered "$target_dir" "$path" "ignore" ""
                ok "Catalogued $path (ignored)"
                ignored=$((ignored + 1))
                ;;
        esac
    done

    echo ""
    printf "  Summary: ${GREEN}%d kept${RESET} (issue filed), ${DIM}%d ignored${RESET}, ${RED}%d removed${RESET}\n" \
        "$kept" "$ignored" "$removed"
}

# ---------------------------------------------------------------------------
# Manifest update
# ---------------------------------------------------------------------------
update_manifest_discovered() {
    local target_dir="$1"
    local path="$2"
    local action="$3"
    local issue_url="$4"
    local today
    today=$(date +%Y-%m-%d)
    local manifest="$target_dir/claude-ops.json"

    if [[ ! -f "$manifest" ]]; then
        return 0
    fi

    if ! command -v jq &>/dev/null; then
        warn "jq not available — skipping manifest update for $path"
        return 0
    fi

    local entry
    if [[ -n "$issue_url" ]]; then
        entry=$(jq -n --arg p "$path" --arg a "$action" --arg d "$today" --arg u "$issue_url" \
            '{path: $p, action: $a, discoveredAt: $d, issueUrl: $u}')
    else
        entry=$(jq -n --arg p "$path" --arg a "$action" --arg d "$today" \
            '{path: $p, action: $a, discoveredAt: $d}')
    fi

    jq --argjson entry "$entry" '
        .discovered = ((.discovered // []) | map(select(.path != $entry.path))) + [$entry]
    ' "$manifest" > "${manifest}.tmp" && mv "${manifest}.tmp" "$manifest"
}

# ---------------------------------------------------------------------------
# GitHub issue creation
# ---------------------------------------------------------------------------
file_github_issue() {
    local item_path="$1"
    local project_name="$2"

    local title="[Discovery] User file: ${item_path}"
    local body
    body=$(cat <<ISSUE_EOF
A user of claude-ops-kit found this file in their \`.claude/\` directory that isn't part of the kit.

- **Project**: ${project_name}
- **Path**: \`${item_path}\`
- **Discovered**: $(date +%Y-%m-%d)

The user chose to **keep** this file and is suggesting it for possible inclusion in the kit.

Please review whether this should become a standard template or optional module.
ISSUE_EOF
    )

    # Check gh availability
    if ! command -v gh &>/dev/null; then
        warn "gh CLI not installed — cannot file issue automatically"
        echo "  File manually at: https://github.com/saddestmartian/claude-ops-kit/issues/new" >&2
        echo ""
        return 0
    fi

    # Check gh auth
    if ! gh auth status &>/dev/null 2>&1; then
        warn "gh not authenticated — cannot file issue automatically"
        echo "  Run 'gh auth login' then re-run, or file manually:" >&2
        echo "  https://github.com/saddestmartian/claude-ops-kit/issues/new" >&2
        echo ""
        return 0
    fi

    # Create the issue
    local issue_url
    issue_url=$(gh issue create \
        --repo "saddestmartian/claude-ops-kit" \
        --title "$title" \
        --body "$body" \
        --label "discovery" \
        2>/dev/null) || {
        warn "Failed to create issue (network error or permissions)"
        echo "  File manually at: https://github.com/saddestmartian/claude-ops-kit/issues/new" >&2
        echo ""
        return 0
    }

    printf "  ${GREEN}→ Issue created: %s${RESET}\n" "$issue_url" >&2
    echo "$issue_url"
}

# ---------------------------------------------------------------------------
# Top-level runner (convenience for callers)
# ---------------------------------------------------------------------------
run_discovery() {
    local kit_root="$1"
    local target_dir="$2"
    local project_name="${3:-unknown-project}"
    local no_discover="${4:-false}"

    if [[ "$no_discover" == true ]]; then
        return 0
    fi

    build_known_paths "$kit_root" "$target_dir"
    discover_unknown_files "$target_dir"

    if [[ ${#UNKNOWN_ITEMS[@]} -eq 0 ]]; then
        ok "No unknown .claude/ files detected"
        return 0
    fi

    header "Unknown .claude/ Files Detected"
    printf "\n  Found %d item(s) not part of claude-ops-kit:\n" "${#UNKNOWN_ITEMS[@]}"

    prompt_disposition
    execute_dispositions "$target_dir" "$project_name"
}
