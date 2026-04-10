# Cloud Setup — claude-ops-kit

## Prerequisites
- Git
- `jq` — `apt-get install jq` or equivalent
- `gh` CLI or `GH_TOKEN` env var for API access
- `curl` for GitHub API fallback if gh unavailable

## First-Session Checklist
1. Verify git: `git --version`
2. Verify jq: `jq --version`
3. Verify GitHub access: `gh auth status` or test token with curl
4. Import memory: `bash scripts/sync-memory.sh import` (if memory-sync has content)
5. Check drift: `bash scripts/check-drift.sh`
