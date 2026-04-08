#!/bin/bash
# sync-memory.sh — Sync Claude Code memory files between local machine and git-tracked backup
#
# Usage:
#   scripts/sync-memory.sh export   — copy memory → .claude/memory-sync/ (before commit/push)
#   scripts/sync-memory.sh import   — copy .claude/memory-sync/ → memory (after pull on new machine)
#
# The memory path is derived from the repo's absolute path, matching Claude Code's convention.

set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
PROJECT_KEY=$(echo "$REPO_ROOT" | tr '/:' '--' | tr '.' '-')
MEMORY_DIR="$HOME/.claude/projects/${PROJECT_KEY}/memory"
SYNC_DIR="$REPO_ROOT/.claude/memory-sync"

case "${1:-}" in
  export)
    if [ ! -d "$MEMORY_DIR" ]; then
      echo "No memory directory found at: $MEMORY_DIR"
      exit 1
    fi
    mkdir -p "$SYNC_DIR"
    # Copy all memory files to sync directory
    cp "$MEMORY_DIR"/*.md "$SYNC_DIR/" 2>/dev/null || true
    # Count files
    COUNT=$(ls -1 "$SYNC_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
    echo "Exported $COUNT memory files to .claude/memory-sync/"
    ;;

  import)
    if [ ! -d "$SYNC_DIR" ]; then
      echo "No sync directory found at: $SYNC_DIR"
      echo "Run 'git pull' first to get the latest memory backup."
      exit 1
    fi
    mkdir -p "$MEMORY_DIR"
    # Copy all synced files to memory directory
    cp "$SYNC_DIR"/*.md "$MEMORY_DIR/" 2>/dev/null || true
    # Count files
    COUNT=$(ls -1 "$MEMORY_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
    echo "Imported memory files to: $MEMORY_DIR ($COUNT files)"
    ;;

  *)
    echo "Usage: scripts/sync-memory.sh [export|import]"
    echo ""
    echo "  export  — copy memory files to git-tracked .claude/memory-sync/"
    echo "  import  — restore memory files from .claude/memory-sync/ to local Claude config"
    exit 1
    ;;
esac
