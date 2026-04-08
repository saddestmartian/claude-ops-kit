# Investigation-First Protocol

## The Pattern
When modifying existing code, your first action MUST be read-only. Trace the execution path from entry point to the code you plan to change before writing anything.

## Why This Exists
The #1 failure mode in Claude Code sessions is: Claude reads a bug report, jumps to the "obvious" fix, and the fix either doesn't work (wrong module) or breaks something else (didn't understand the call chain). The second fix then compensates for the first, creating a stacking-fix spiral.

## War Stories

### The Dead Module Trap (Session 47)
Claude found a module with the exact bug described, fixed it perfectly — but the module wasn't `require()`d anywhere. It was dead code from a prior refactor. The active module was a different file with a similar name. 30 minutes wasted.

**Lesson:** Always `grep -r "require.*ModuleName" src/` before editing. Zero matches = dead code.

### The Stacking Fix Spiral (Session 52)
1. Bug: items not appearing in Fitting Room
2. Fix #1: Modified the insertion function (wrong assumption — insertion was fine)
3. Fix #2: Added a fallback path to compensate for fix #1 (now two code paths for the same thing)
4. Fix #3: Debug logging to figure out why fix #2 created duplicates
5. Eventually: rolled back all 3 fixes, traced from the event listener (the actual bug was in EventBridge cleanup)

**Lesson:** If fix #2 compensates for fix #1, STOP. The assumption behind fix #1 was wrong.

## How to Apply
1. **Read the target code** — understand what it currently does
2. **Read the calling code** — understand how the module is consumed
3. **Verify the module is live** — search for imports/requires
4. **Trace the execution path** — from entry point to target
5. **Only then** — implement the change

Skip this for greenfield work or trivial edits where the path is obvious.
