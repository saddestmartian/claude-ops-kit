# Playbook — How We Work

This directory contains narrative documentation of our workflow patterns, learnings, and retrospectives. Unlike `.claude/rules/` (terse, auto-loaded instructions), these are reference material explaining the *reasoning* behind each pattern.

## Patterns
- [Investigation-First](patterns/investigation-first.md) — Why read-only first actions prevent cascading mistakes
- [Anti-Spiral](patterns/anti-spiral.md) — Six rules that prevent fix-on-fix loops and scope creep
- [Session Workflow](patterns/session-workflow.md) — Full session lifecycle from start to handoff
- [Memory Sync](patterns/memory-sync.md) — Cross-machine memory strategy
- [Model Routing](patterns/model-routing.md) — When to use Opus vs Sonnet
- [Sub-Agent Orchestration](patterns/sub-agent-orchestration.md) — Parallel worktree agent patterns
- [Backlog-Driven Dev](patterns/backlog-driven-dev.md) — JSON backlog + viewer workflow
- [Bug-Fix Protocol](patterns/bug-fix-protocol.md) — Test-driven bug fix flow

## Learnings
- [Trust Erosion Patterns](learnings/trust-erosion-patterns.md) — Actions that break user trust
- [Compaction Survival](learnings/compaction-survival.md) — Post-compaction verification
- [Cross-Platform Gotchas](learnings/cross-platform-gotchas.md) — Windows/macOS/Cloud differences
- [Constraint Budget Research](learnings/constraint-budget-research.md) — Academic findings on rule design, prohibition framing, and complexity profiles

## Retrospectives
Session retrospectives are stored in `retrospectives/` with dated filenames.
