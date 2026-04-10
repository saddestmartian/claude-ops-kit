## Investigation-First

NEVER write code as your first action when modifying existing code or debugging. First action MUST be read-only: trace the execution path from entry point to target.

NEVER edit a module without verifying it's actively used — search for imports/requires. Zero matches = dead code, do not touch.

NEVER apply a follow-up fix without re-investigating — if the first change didn't work, the assumption was wrong.

Exception: greenfield work or trivial edits where the path is obvious.
