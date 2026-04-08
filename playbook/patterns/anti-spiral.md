# Anti-Spiral Rules

## The Pattern
Six rules that prevent the most common Claude Code failure modes: guess-and-check debugging, scope creep, and fix-on-fix spirals.

## The Rules

### 1. Clarify Before Coding
If a bug report or request is ambiguous, STOP and ask the user. The cost of one clarifying question is always less than the cost of implementing the wrong thing.

### 2. Detect Stacking Fixes
If fix #2 compensates for fix #1, the assumption behind fix #1 was wrong. Don't layer more code — step back and re-examine.

**Signal:** "I need to add this because the previous change didn't quite work" → STOP.

### 3. Three Whiffs
Three "found it / wait actually" cycles means you're guessing, not investigating. STOP. Step back to first principles. Re-read from the entry point.

### 4. Scope Escalation
If work exceeds 3+ files or has architectural implications, discuss with the user before continuing. Large silent changes are hard to review and easy to get wrong.

### 5. Implementation-First Thinking
Before patching a bug, ask: "What would correct code look like if I wrote it from scratch?" This reframes the problem from "what's wrong" to "what's right" and often reveals simpler solutions.

### 6. Verify Before Implementing
Before starting a multi-item plan, check actual codebase state for each item. Tasks may already be done, modules may have moved, or assumptions may be wrong.

## When These Rules Fire
- Rules 1-3: During debugging and bug fixes
- Rule 4: During feature implementation
- Rule 5: During any code change
- Rule 6: At the start of any multi-task session
