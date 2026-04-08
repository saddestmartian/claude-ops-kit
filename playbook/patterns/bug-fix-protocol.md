# Bug-Fix Protocol — Test-Driven

## The Flow
1. **Read** relevant source files — understand current behavior
2. **Write** a failing test that reproduces the bug; confirm it fails
3. **Implement** the minimal fix
4. **Run** full test suite — if any test fails, diagnose and fix (up to 3 retries)
5. **Move on** only when ALL tests pass
6. **Commit** one atomic commit per bug

## Why Test-First
- The test proves the bug exists (not just "I think it's broken")
- The test proves the fix works (not just "it looks right")
- The test prevents regression (future changes can't reintroduce the bug silently)
- The test documents the expected behavior (future developers understand the constraint)

## Common Traps
- **Fixing symptoms, not causes:** A UI element not showing up might be a state management bug, not a rendering bug. Trace the data flow.
- **Assuming API methods exist:** Always grep or search before using a method name. Autocomplete lies.
- **Fixing in the wrong module:** The module with the bug might not be the active one — verify it's `require()`d.
- **Over-fixing:** Fix the bug, not the surrounding code. Don't refactor while fixing.
