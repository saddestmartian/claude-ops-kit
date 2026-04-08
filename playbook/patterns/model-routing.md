# Model Routing — Opus vs Sonnet

## When to Use Opus
- **Planning & architecture** — system design, feature planning, roadmap decisions
- **Complex debugging** — multi-module issues requiring deep reasoning
- **Design consultation** — UX decisions, trade-off analysis
- **Code review** — reviewing complex PRs or architectural changes
- **Research synthesis** — combining multiple sources into a decision

## When to Use Sonnet
- **Implementation** — writing code for a defined plan
- **Single-module features** — isolated changes with clear scope
- **Break-fix cycles** — quick bug fixes with known root cause
- **Repetitive tasks** — bulk edits, renaming, format changes
- **Sub-agent work** — parallel implementation tasks in worktrees

## Model Routing in Practice
- Use `opusplan` for automatic routing based on task complexity
- Use `/model` to switch manually when you know what's needed
- Sub-agents default to Sonnet unless the task requires architectural decisions

## The Architect/Worker Pattern
- **Opus** owns architectural decisions, designs the plan, reviews output
- **Sonnet sub-agents** execute implementation in parallel worktrees
- Each sub-agent gets a scoped task with clear boundaries
- Opus verifies top findings against actual source before accepting

This pattern scales well: Opus thinks once, Sonnet executes many times in parallel.
