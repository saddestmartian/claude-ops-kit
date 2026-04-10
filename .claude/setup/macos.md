# macOS Setup — claude-ops-kit

## Prerequisites
- Git (Xcode CLT or Homebrew)
- `jq` — `brew install jq`
- `gh` CLI — `brew install gh`
- Node.js (optional, for testing npm-based stack presets)

## First-Session Checklist
1. Verify git: `git --version`
2. Verify jq: `jq --version`
3. Verify gh: `gh auth status`
4. Import memory: `bash scripts/sync-memory.sh import` (if memory-sync has content)
5. Check drift: `bash scripts/check-drift.sh`
