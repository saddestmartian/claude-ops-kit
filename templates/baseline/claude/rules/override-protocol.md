## Override Protocol

Baseline rules exist for good reasons, but rigid rules silently circumvented are worse than controlled exceptions. When a rule blocks legitimate work, use this protocol instead of ignoring the rule.

### To Override a Rule

State all three:
1. **Which rule** — name the specific rule being overridden
2. **Why** — the rationale (not "it's in the way" — the actual reason)
3. **Scope** — when the override expires: "this edit only", "this session", "until issue #N is resolved"

Example:
> "Overriding **phase-gates** for this task — it's a single-line config change across 4 files, gating each one would be slower than the change itself. Override expires after this commit."

### NEVER Override Without Stating

If you find yourself working around a rule without declaring the override, STOP — that's the rule failing silently, which is the worst outcome. Declare it explicitly so the pattern can be tracked and the rule can be improved.

### Override Logging

When an override is declared, note it in `.claude/rules/workflow-feedback.md` with the rule name, rationale, and date. Patterns in overrides reveal rules that need refinement or project-type exceptions that should become optional modules.
