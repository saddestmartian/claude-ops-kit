# Session Workflow

## The Full Session Lifecycle

### Starting a Session
1. **Import memory:** `scripts/sync-memory.sh import`
2. **Read PROJECT_STATE.md** — understand current priorities and context
3. **Check git state:** `git log --oneline -10`, `git status`, `git stash list`
4. **Verify hooks:** `git config core.hooksPath` → `.githooks`
5. **Create a feature branch** — never commit directly to main

### During Work
- **Branch workflow:** one feature branch per session or task
- **Commit often:** after every meaningful change with descriptive messages
- **Report at milestones:** don't go silent through multi-file changes
- **Use `/clear` between unrelated tasks** to avoid context accumulation

### Ending a Session (`/handoff`)
1. **Update backlog.json** — statuses + claudeComments for all tasks touched
2. **Update PROJECT_STATE.md** — completed work, next priorities, gotchas, starter prompt
3. **Sync reference files** — REFERENCE_MAP.md, CLAUDE.md if conventions changed
4. **Verify sync:** `scripts/verify-sync.sh`
5. **Run lint:** ensure no regressions
6. **Export memory:** `scripts/sync-memory.sh export`
7. **Commit, push, PR**

### The Starter Prompt
Every session ends with a starter prompt in PROJECT_STATE.md — a paste-ready prompt for the next session. It should include:
- Which branch to start from
- Which task IDs to pick up
- Any setup steps needed
- What was left incomplete and why

### Post-Compaction
When Claude's context is compressed mid-session:
- Don't trust task status claims without verifying against backlog.json
- Re-verify branch state: `git branch --show-current` + `git log --oneline -5`
- Commit messages are durable — include task IDs AND their status in bodies
