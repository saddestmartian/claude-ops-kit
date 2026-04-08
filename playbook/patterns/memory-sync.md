# Memory Sync — Cross-Machine Strategy

## The Problem
Claude Code memory is stored locally at `~/.claude/projects/{key}/memory/`. When you work from multiple machines (Mac, PC, cloud), each machine has its own memory that doesn't sync.

## The Solution
Git-tracked memory backup at `.claude/memory-sync/` with bi-directional merge.

### Export (end of session, before push)
```bash
scripts/sync-memory.sh export
```
Merges local memory → `.claude/memory-sync/`. Newer files win. Deleted files are tracked via `.sync-manifest` so removals propagate.

### Import (start of session, after pull)
```bash
scripts/sync-memory.sh import
```
Merges `.claude/memory-sync/` → local memory. Same newer-wins resolution. Creates the local memory directory if this is a fresh clone.

### Status (check for drift)
```bash
scripts/sync-memory.sh status
```
Shows what's different between local and git-tracked copies. Useful for diagnosing sync issues.

### Dry Run
```bash
scripts/sync-memory.sh export --dry-run
```
Preview what would change without applying anything.

## How the Path is Derived
Claude Code uses the repo's absolute path as a project key:
- macOS: `/Users/mike/dev/myproject` → `--Users-mike-dev-myproject`
- Windows (Git Bash): `/c/devprojects/myproject` → `C--devprojects-myproject`

The sync script resolves the local memory directory by trying multiple candidate paths:
1. Standard filesystem path key (current machine)
2. Windows-style path key variant (Git Bash normalization)
3. Fuzzy match by repo basename (handles path differences between machines)

This means the script works even when the repo lives at `/Users/mike/dev/myproject` on your Mac and `C:\devprojects\myproject` on your PC.

## Merge Strategy
- **Both locations have the file** → newer file (by mtime) wins
- **File exists only in source** → copied to destination
- **File was in source before but is now deleted** → removed from destination (tracked via `.sync-manifest`)
- **File exists only in destination and wasn't tracked before** → preserved (it's new from the other side)

## What to Sync
- Memory files (`.md` files with frontmatter: name, description, type)
- MEMORY.md index

## What NOT to Sync
- `settings.json` / `settings.local.json` (machine-specific)
- `.claude/worktrees/` (ephemeral)
- Session transcripts (`.jsonl` files — too large, machine-specific)

## Automation via Hooks

For hands-free sync, configure Claude Code hooks in `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [],
    "PostToolUse": [],
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash scripts/sync-memory.sh import 2>/dev/null || true"
          }
        ]
      }
    ],
    "SessionStop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash scripts/sync-memory.sh export 2>/dev/null || true"
          }
        ]
      }
    ]
  }
}
```

This auto-imports on session start and auto-exports on session stop — no manual step needed.

## Integration with Handoff
The `/handoff` skill includes memory export as a step. Session start includes import. With hooks configured, this happens automatically.
