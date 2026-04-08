# Backlog-Driven Development

## The System
A JSON-based task registry (`backlog.json`) paired with a human-readable session document (`PROJECT_STATE.md`) and an HTML viewer (`backlog-viewer.html`).

### backlog.json — Single Source of Truth
- Every task has a unique ID (`PREFIX-NNN`)
- Tasks have status, type, priority, effort, and free-text fields
- `claudeComments` field captures what Claude observed/did
- `userComments` field captures user decisions and context
- 10-status workflow: Backlog → Not started → Blocked → Deferred → In progress → In Review → Testing → Merged → Verified → Done

### PROJECT_STATE.md — Session Context
- Read at the start of every session
- Contains: what's done, what's in progress, next priorities, known issues
- Includes a **starter prompt** — paste-ready context for the next session
- Retains the 3 most recent session summaries; older ones pruned (git log has history)

### backlog-viewer.html — Visual Dashboard
- Dark-themed, standalone HTML file
- Kanban board view (drag-and-drop columns by status)
- Table view with sortable columns and filters
- Stale task detection (badges for tasks needing attention)
- Loads backlog.json via file input or relative path

## Workflow
1. **Start of session:** Read PROJECT_STATE.md → pick task from backlog
2. **During work:** Update task status to "In progress" when starting
3. **On completion:** Mark "Done", update claudeComments
4. **End of session:** Sync both files, update PROJECT_STATE.md with next priorities
5. **New discoveries:** Add tasks with next available ID

## Branch-Aware Reads
Always verify you're on `main` before reading backlog.json for task state. Feature branches carry stale copies.
