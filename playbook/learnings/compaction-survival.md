# Compaction Survival

When Claude Code compresses prior messages (approaches context limits), information is lost. These practices help survive compaction.

## What to Preserve
Always preserve in your working context:
- The list of modified files
- Current task state (what's done, what's in progress)
- Module dependency relationships relevant to current work
- Any unresolved bugs or decisions

## Post-Compaction Verification
After noticing compaction happened:
1. **Don't trust task status claims** from the summary without verifying against `backlog.json` on the correct branch
2. **Re-verify branch state:** `git branch --show-current` + `git log --oneline -5`
3. **Re-read critical context:** PROJECT_STATE.md if it was relevant to your work

## Durable Information
These survive compaction because they're in files:
- **Commit messages** — include task IDs AND their status in the body
- **PROJECT_STATE.md** — current priorities and session context
- **backlog.json** — task statuses
- **.claude/MEMORY.md** — accumulated patterns and task ledger

## Anti-Pattern
Don't rely solely on conversation memory for task tracking. If a task is important, write its status to a file. Conversation context is volatile; files are durable.
