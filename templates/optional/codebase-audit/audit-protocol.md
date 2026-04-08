## Codebase Audit Protocol

When auditing code sections or the full codebase:

1. Run parallel sub-agents (up to 4), each covering a different directory or concern
2. Each agent must: document findings with file paths and line numbers, verify each finding by reading actual source
3. After all agents report: deduplicate and prioritize findings by severity
4. Implement fixes in waves — each wave on a separate branch with atomic commits
5. Run lint + test suite after each wave. Only create a PR for waves where all checks pass
6. If a wave fails, diagnose and retry once before flagging for review
7. Track progress in audit-progress.md (create if needed)

### Audit Categories
- Dead code (unreferenced modules, unused exports)
- Design system violations (hardcoded values, inconsistent tokens)
- Security (input validation, secret handling)
- Performance (unnecessary re-renders, N+1 queries, unbounded loops)
- Error handling (swallowed errors, missing fallbacks at system boundaries)
- Dependency health (circular imports, outdated packages)
- Test coverage gaps (critical modules without tests)
- Documentation drift (REFERENCE_MAP, CLAUDE.md out of date)

### Sub-Agent Rules
- Read-only during audit phase — do NOT modify files
- Commit findings to a named branch (e.g., `audit/<scope>`) before finishing
- Verify each finding by reading actual source (don't trust grep alone)
