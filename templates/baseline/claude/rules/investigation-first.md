## Investigation-First Protocol

When modifying existing code or debugging:

1. **First action MUST be read-only** — trace the execution path from entry point to the code you plan to change.
2. **Verify the module is actively used** — search for imports/requires. If zero matches, it may be dead code. Do NOT edit dead code.
3. **Read the calling code**, not just the target code — understand how the module is consumed.
4. **If a change doesn't produce expected results:** STOP. Don't apply a second fix on top. The assumption that led to fix #1 was wrong — re-investigate from the entry point.

This does NOT apply to greenfield work or simple edits where the path is obvious.
