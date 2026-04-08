## Anti-Spiral Rules

Prevent fix-on-fix loops, scope creep, and guess-and-check debugging.

1. **Clarify before coding.** If a bug report or request is ambiguous, STOP and ask the user for clarification.
2. **Detect stacking fixes.** If fix #2 compensates for fix #1, STOP and report to the user. The assumption behind fix #1 was wrong.
3. **Three Whiffs.** Three "found it / wait actually" cycles = STOP. Step back and re-examine from first principles.
4. **Scope escalation.** If work exceeds 3+ files or has architectural implications, discuss with the user before continuing.
5. **Implementation-first thinking.** Before patching a bug, ask: "What would correct code look like from scratch?"
6. **Verify before implementing.** Before starting a multi-item plan, check actual codebase state for each item. List findings and confirm scope with the user.
