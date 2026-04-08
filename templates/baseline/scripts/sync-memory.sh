#!/bin/bash
# sync-memory.sh — Bi-directional memory sync between Claude Code local storage and git-tracked backup
#
# Usage:
#   scripts/sync-memory.sh export   — merge local memory → .claude/memory-sync/ (before commit/push)
#   scripts/sync-memory.sh import   — merge .claude/memory-sync/ → local memory (after pull on new machine)
#   scripts/sync-memory.sh status   — show sync status (what's different between local and git)
#
# Improvements over v1:
#   - Bi-directional merge: newer file wins (by mtime), no silent overwrites
#   - Deleted file handling: removals are tracked via .sync-manifest
#   - Multi-path resolution: tries git-remote-based key first, falls back to filesystem path
#   - Dry-run support: pass --dry-run to preview changes without applying

set -euo pipefail

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Error: not inside a git repository. Run this from your project directory."
    exit 1
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
SYNC_DIR="$REPO_ROOT/.claude/memory-sync"
MANIFEST="$SYNC_DIR/.sync-manifest"

GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[0;33m"
DIM="\033[2m"
RESET="\033[0m"

ok()   { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
info() { printf "${CYAN}→ %s${RESET}\n" "$1"; }
warn() { printf "${YELLOW}⚠ %s${RESET}\n" "$1"; }
dim()  { printf "${DIM}  %s${RESET}\n" "$1"; }

DRY_RUN=false
for arg in "$@"; do
    [[ "$arg" == "--dry-run" ]] && DRY_RUN=true
done

# ---------------------------------------------------------------------------
# Resolve the local memory directory
# ---------------------------------------------------------------------------
# Claude Code keys projects by filesystem path: /a/b/c → --a-b-c (on Unix) or C:/a/b → C--a-b (on Windows)
# Problem: same repo at different paths on different machines = different keys
# Solution: try multiple candidate paths, use the first one that exists

resolve_memory_dir() {
    # Candidate 1: current filesystem path (standard Claude Code behavior)
    local fs_key
    fs_key=$(echo "$REPO_ROOT" | tr '/:.' '-' | sed 's/^-*//')
    local candidate1="$HOME/.claude/projects/${fs_key}/memory"

    # Candidate 2: Windows-style path key (for Git Bash on Windows)
    local win_key
    win_key=$(echo "$REPO_ROOT" | sed 's|^/\([a-zA-Z]\)/|\1:/|' | tr '/:.' '-' | sed 's/^-*//')
    local candidate2="$HOME/.claude/projects/${win_key}/memory"

    # Candidate 3: scan projects dir for a directory containing matching memory files
    # (handles path changes between machines)

    # Return the first existing candidate
    if [[ -d "$candidate1" ]]; then
        echo "$candidate1"
        return 0
    elif [[ -d "$candidate2" ]]; then
        echo "$candidate2"
        return 0
    fi

    # Candidate 3: fuzzy match — look for a projects dir whose name ends with the repo basename
    local repo_name
    repo_name=$(basename "$REPO_ROOT")
    if [[ -d "$HOME/.claude/projects" ]]; then
        for dir in "$HOME/.claude/projects"/*; do
            if [[ -d "$dir/memory" && "$(basename "$dir")" == *"$repo_name" ]]; then
                echo "$dir/memory"
                return 0
            fi
        done
    fi

    # No existing memory dir found — return the standard path for creation
    echo "$candidate1"
    return 1
}

MEMORY_DIR=$(resolve_memory_dir) || true

# ---------------------------------------------------------------------------
# Sync manifest (tracks which files exist, for delete detection)
# ---------------------------------------------------------------------------
load_manifest() {
    if [[ -f "$MANIFEST" ]]; then
        cat "$MANIFEST"
    fi
}

save_manifest() {
    local dir="$1"
    # List all .md files currently in sync dir (minus the manifest itself)
    ls -1 "$dir"/*.md 2>/dev/null | xargs -I{} basename {} | sort > "$MANIFEST"
}

# ---------------------------------------------------------------------------
# Bi-directional merge logic
# ---------------------------------------------------------------------------
# For each .md file found in either location:
#   - exists in both → newer file (by mtime) wins
#   - exists only in source → copy to destination
#   - existed before (in manifest) but gone from source → remove from destination

merge_files() {
    local from_dir="$1"
    local to_dir="$2"
    local direction="$3"  # "export" or "import"

    local copied=0 updated=0 removed=0 skipped=0

    mkdir -p "$to_dir"

    # Phase 1: Copy/update files from source to destination
    for src_file in "$from_dir"/*.md; do
        [[ -f "$src_file" ]] || continue
        local fname
        fname=$(basename "$src_file")
        local dst_file="$to_dir/$fname"

        if [[ ! -f "$dst_file" ]]; then
            # New file — copy it
            if $DRY_RUN; then
                info "[dry-run] Would copy: $fname"
            else
                cp "$src_file" "$dst_file"
                ok "Added: $fname"
            fi
            copied=$((copied + 1))
        else
            # Both exist — compare mtimes, newer wins
            local src_mtime dst_mtime
            src_mtime=$(stat -c %Y "$src_file" 2>/dev/null || stat -f %m "$src_file" 2>/dev/null || echo 0)
            dst_mtime=$(stat -c %Y "$dst_file" 2>/dev/null || stat -f %m "$dst_file" 2>/dev/null || echo 0)

            if [[ "$src_mtime" -gt "$dst_mtime" ]]; then
                if $DRY_RUN; then
                    info "[dry-run] Would update: $fname (source is newer)"
                else
                    cp "$src_file" "$dst_file"
                    ok "Updated: $fname (source is newer)"
                fi
                updated=$((updated + 1))
            else
                dim "Unchanged: $fname"
                skipped=$((skipped + 1))
            fi
        fi
    done

    # Phase 2: Reverse copy — files only in destination that are also newer
    for dst_file in "$to_dir"/*.md; do
        [[ -f "$dst_file" ]] || continue
        local fname
        fname=$(basename "$dst_file")
        local src_file="$from_dir/$fname"

        if [[ ! -f "$src_file" ]]; then
            # File exists in destination but not source
            # Check manifest: if it was in source before, it was intentionally deleted
            if [[ -f "$MANIFEST" ]] && grep -qF "$fname" "$MANIFEST"; then
                if $DRY_RUN; then
                    info "[dry-run] Would remove: $fname (deleted from source)"
                else
                    rm "$dst_file"
                    warn "Removed: $fname (deleted from source)"
                fi
                removed=$((removed + 1))
            else
                # Not in manifest — it's a new file from the other side, leave it
                dim "Kept: $fname (only in destination)"
                skipped=$((skipped + 1))
            fi
        fi
    done

    echo ""
    printf "  %s complete: %d added, %d updated, %d removed, %d unchanged\n" \
        "$direction" "$copied" "$updated" "$removed" "$skipped"
}

# ---------------------------------------------------------------------------
# Status command
# ---------------------------------------------------------------------------
show_status() {
    echo ""
    echo "Memory Sync Status"
    echo ""

    if [[ ! -d "$MEMORY_DIR" ]]; then
        warn "Local memory directory not found: $MEMORY_DIR"
        echo "  (No Claude Code sessions have created memory for this project on this machine)"
    else
        local local_count
        local_count=$(ls -1 "$MEMORY_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
        printf "  Local:  %s (%d files)\n" "$MEMORY_DIR" "$local_count"
    fi

    if [[ ! -d "$SYNC_DIR" ]]; then
        warn "Sync directory not found: $SYNC_DIR"
    else
        local sync_count
        sync_count=$(ls -1 "$SYNC_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
        printf "  Synced: %s (%d files)\n" "$SYNC_DIR" "$sync_count"
    fi

    # Show differences
    if [[ -d "$MEMORY_DIR" && -d "$SYNC_DIR" ]]; then
        echo ""
        local only_local=0 only_sync=0 different=0

        for f in "$MEMORY_DIR"/*.md; do
            [[ -f "$f" ]] || continue
            local fname
            fname=$(basename "$f")
            if [[ ! -f "$SYNC_DIR/$fname" ]]; then
                info "Local only: $fname"
                only_local=$((only_local + 1))
            elif ! diff -q "$f" "$SYNC_DIR/$fname" &>/dev/null; then
                warn "Different: $fname"
                different=$((different + 1))
            fi
        done

        for f in "$SYNC_DIR"/*.md; do
            [[ -f "$f" ]] || continue
            local fname
            fname=$(basename "$f")
            if [[ ! -f "$MEMORY_DIR/$fname" ]]; then
                info "Sync only: $fname"
                only_sync=$((only_sync + 1))
            fi
        done

        if [[ $only_local -eq 0 && $only_sync -eq 0 && $different -eq 0 ]]; then
            ok "In sync — no differences"
        fi
    fi
    echo ""
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
case "${1:-}" in
    export)
        echo ""
        echo "Memory Sync: Export (local → git)"
        echo ""

        if [[ ! -d "$MEMORY_DIR" ]]; then
            warn "No local memory directory found at: $MEMORY_DIR"
            echo "  No Claude Code sessions have written memory for this project on this machine."
            exit 1
        fi

        info "Source: $MEMORY_DIR"
        info "Target: $SYNC_DIR"
        echo ""

        merge_files "$MEMORY_DIR" "$SYNC_DIR" "Export"

        # Update manifest after export
        if ! $DRY_RUN; then
            save_manifest "$SYNC_DIR"
        fi
        ;;

    import)
        echo ""
        echo "Memory Sync: Import (git → local)"
        echo ""

        if [[ ! -d "$SYNC_DIR" ]]; then
            warn "No sync directory at: $SYNC_DIR"
            echo "  Run 'git pull' first to get the latest memory backup."
            exit 1
        fi

        # If memory dir doesn't exist yet, create it at the standard path
        if [[ ! -d "$MEMORY_DIR" ]]; then
            info "Creating local memory directory: $MEMORY_DIR"
            mkdir -p "$MEMORY_DIR"
        fi

        info "Source: $SYNC_DIR"
        info "Target: $MEMORY_DIR"
        echo ""

        merge_files "$SYNC_DIR" "$MEMORY_DIR" "Import"
        ;;

    status)
        show_status
        ;;

    *)
        echo "Usage: scripts/sync-memory.sh <command> [--dry-run]"
        echo ""
        echo "Commands:"
        echo "  export     Merge local memory → .claude/memory-sync/ (before commit/push)"
        echo "  import     Merge .claude/memory-sync/ → local memory (after pull/clone)"
        echo "  status     Show sync status (differences between local and git)"
        echo ""
        echo "Options:"
        echo "  --dry-run  Preview changes without applying them"
        echo ""
        echo "Memory sync uses bi-directional merge with newer-file-wins resolution."
        echo "Deleted files are tracked via .sync-manifest to propagate removals."
        exit 1
        ;;
esac
