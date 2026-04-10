## Session Summary — 2026-04-10

### Completed
- **Skill-driven onboarding** — `/claude-ops-kit` single-entry skill replacing shell-script init/adopt/upgrade
  - SKILL.md router with auto-detect + user-confirmed routing
  - 6 procedure docs: assess, init, adopt, upgrade, evaluate, contribute
- **Research-driven rule optimization** — based on Perplexity deep-dive across 30+ academic/industry sources
  - All 8 baseline rules rewritten with prohibition-first framing (~28 -> ~16 effective sub-constraints)
  - Constraint budget research saved to `playbook/learnings/constraint-budget-research.md`
- **Solo/Team/Enterprise complexity profiles** — auto-detect recommends, user always chooses
- **AGENTS.md template** — cross-tool compatibility (Codex, Copilot, Cursor, Windsurf)
- **Override protocol** — sanctioned rule escape hatch with rationale + expiry + logging
- **Enriched project registry** — evalScore, evalBreakdown, installedModules, maturity, summary fields
- **Contribution pipeline** — `registry/contributions/` for inbound pattern triage
- **Self-bootstrap** — kit adopted onto itself (Team profile, 31 files)
- **Drift check** — `scripts/check-drift.sh` + SessionStart hook catches installed-vs-template divergence
- **VERSION bumped to 1.2.0**

### Next Up (priority order)
1. **Test `/claude-ops-kit` on a real user project** — ugc-world-service or chaos-carl-bot are good candidates (no kit installed, existing repos)
2. **Process inbound contributions** — ugc-world has 11 custom rules; assess which are baseline/optional/snippet/abstain
3. **Build the inbound assessment flow** — when session starts in this repo, check `registry/contributions/` for pending items
4. **Wire `/handoff` as an invocable skill** — currently exists as SKILL.md reference but isn't registered in the Claude Code harness
5. **Consider CI/GitHub Actions** — automated drift check, changelog validation, template rendering tests

### Known Issues / Gotchas
- `/handoff` skill not wired as invocable — SKILL.md exists but Claude Code doesn't auto-register it as a slash command. Need to investigate how skills are registered vs. just being reference docs.
- This repo is both template source AND consumer — drift between `.claude/rules/` and `templates/baseline/claude/rules/` must be monitored. `check-drift.sh` handles this on SessionStart.
- Shell scripts (init.sh, adopt.sh, upgrade.sh) are legacy but not deprecated — some users may prefer CLI-driven setup.
- `scripts/check-version.sh` and `scripts/sync-memory.sh` were copied from templates but may reference template variables that don't apply to this meta-tool repo.

### Starter Prompt
> Picking up claude-ops-kit development. Read PROJECT_STATE.md for context. Last session (2026-04-10) built the entire skill-driven onboarding system, optimized rules based on academic research, added complexity profiles + AGENTS.md + override protocol, and self-bootstrapped the kit onto itself. Priority is testing the `/claude-ops-kit` skill on a real project (try ugc-world-service) and processing ugc-world's 11 custom rules through the contribution pipeline.
