# Memory Sync — Cross-Machine Strategy

## The Problem
Claude Code memory is stored locally at `~/.claude/projects/{key}/memory/`. When you work from multiple machines (Mac, PC, cloud), each machine has its own memory that doesn't sync.

## The Solution
Git-tracked memory backup at `.claude/memory-sync/`.

### Export (end of session)
```bash
scripts/sync-memory.sh export
```
Copies memory files from `~/.claude/projects/{key}/memory/` → `.claude/memory-sync/`. Committed and pushed with the session's work.

### Import (start of session)
```bash
scripts/sync-memory.sh import
```
Copies `.claude/memory-sync/` → `~/.claude/projects/{key}/memory/`. Run after `git pull` on any machine.

## How the Path is Derived
Claude Code uses the repo's absolute path as a project key, with `/`, `:`, and `.` replaced:
- macOS: `/Users/mike/dev/myproject` → `--Users-mike-dev-myproject`
- Windows: `C:/devprojects/myproject` → `C--devprojects-myproject`

The `sync-memory.sh` script auto-derives this from `git rev-parse --show-toplevel`.

## What to Sync
- Memory files (`.md` files with frontmatter: name, description, type)
- MEMORY.md index

## What NOT to Sync
- `settings.json` (machine-specific)
- `.claude/worktrees/` (ephemeral)

## Integration with Handoff
The `/handoff` skill includes memory export as step 5. The session start procedure includes memory import as step 1. This creates a natural sync cycle.
