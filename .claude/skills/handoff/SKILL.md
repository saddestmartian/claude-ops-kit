# Skill: Session Handoff (`/handoff`)

## When to Use
End of a session when work is incomplete or paused — preserves context for the next session.

## Procedure

### 1. Gather Session Context
- Run `git log --oneline` since session start to identify all changes
- Note any open PRs: `gh pr list --state open`

### 2. Build Handoff Summary
Write/update `PROJECT_STATE.md` with these sections:

```markdown
## Session Summary — YYYY-MM-DD

### Completed
- Description of what was done (PR #N — merged/open)

### Next Up (priority order)
1. Description — why it's next

### Known Issues / Gotchas
- Issue description — context on why it matters

### Starter Prompt
> Paste-ready prompt for the next session to resume seamlessly.
```

Retain the 3 most recent session summaries. Prune older ones.

### 3. Sync Reference Files
- `REFERENCE_MAP.md` — if modules were added/removed/renamed, update
- `CLAUDE.md` — if conventions or patterns changed, reflect them
- `.claude/MEMORY.md` — update index if new memories were created

### 4. Check Drift
- Run `bash scripts/check-drift.sh` — verify installed rules match templates

### 5. Export Memory
- Run `scripts/sync-memory.sh export` if present

### 6. Commit & Push
- Stage changes: `git add PROJECT_STATE.md REFERENCE_MAP.md CLAUDE.md .claude/`
- Commit: `git commit -m "chore: session handoff — <brief summary>"`
- Push: `git push -u origin HEAD`
- Output the PR URL if on a feature branch

## Rules
- Never skip the sync step (#3) — stale tracking files cause wrong assumptions
- The starter prompt must be specific enough that a fresh context can resume without re-reading everything
