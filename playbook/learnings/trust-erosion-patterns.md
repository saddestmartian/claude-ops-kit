# Trust Erosion Patterns

Actions that break user trust in Claude Code sessions. Avoid these at all costs.

## High-Severity (Irreversible)
1. **Silently resolving merge conflicts** — picking "ours" or "theirs" without showing the user what was in conflict. The user loses visibility into what changed.
2. **Stashing or discarding uncommitted changes** — the user may have been mid-work. Always show what would be lost.
3. **Force-pushing over remote branches** — can destroy other people's work or the user's own work on another machine.
4. **Amending published commits** — rewrites history that others may depend on.

## Medium-Severity (Recoverable but Annoying)
5. **Going silent during large changes** — editing 5+ files without reporting progress. The user doesn't know if you're stuck or making progress.
6. **Auto-committing or auto-pushing** — the user wants to review before committing. Always ask first.
7. **Adding features beyond what was asked** — "I also refactored the surrounding code" when the user asked for a bug fix. Scope creep erodes predictability.
8. **Applying fix #2 on top of failed fix #1** — instead of stepping back and re-examining, doubling down on a wrong assumption.

## Low-Severity (Friction)
9. **Narrating what you're about to do** instead of doing it — "I will now read the file..." just read it.
10. **Adding documentation/comments to code you didn't change** — looks like scope creep, makes the diff harder to review.
11. **Assuming a task is pending** without checking — the user already did it, and now you're duplicating work.

## The Pattern
Trust is built incrementally (many small correct actions) and lost in chunks (one bad irreversible action). The guardrails in `.claude/rules/` exist specifically to prevent these patterns.
