## Git Safety

These operations are irreversible and have caused trust erosion in past sessions.

- **Never silently resolve merge conflicts.** Flag all conflicts to the user with before/after context before proceeding.
- **Never stash or discard uncommitted changes without investigating.** Show the user what would be stashed/lost and get approval.
- **Never force-push without explicit user approval.** Warn if pushing to main/master.
- **Never amend published commits** without user approval — this rewrites history others may depend on.
- **Prefer new commits over amends.** When a pre-commit hook fails, the commit didn't happen — `--amend` would modify the PREVIOUS commit, potentially destroying work.
