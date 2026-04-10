# Changelog

All notable changes to claude-ops-kit are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/).

## [1.2.0] - 2026-04-10

### Added
- **Skill-driven onboarding** — `/claude-ops-kit` skill replaces shell-script-driven init/adopt/upgrade
  - Single entry point that auto-detects project state and routes to the correct flow
  - Conversational onboarding instead of yes/no/keep/merge prompts
  - Intelligent merge that reads and understands existing files before proposing changes
- **Procedure docs** — modular reference docs for each onboarding flow:
  - `procedures/assess.md` — 7-category evaluation rubric
  - `procedures/init.md` — full init for new projects
  - `procedures/adopt.md` — intelligent merge for existing projects
  - `procedures/upgrade.md` — version-aware selective upgrade
  - `procedures/evaluate.md` — project comprehensiveness scoring
  - `procedures/contribute.md` — share patterns back to the kit
- **Project evaluation scoring** — 7-category rubric (rules, memory, skills, agents, git, docs, session) with maturity labels
- **Contribution workflow** — catalog and triage user customizations for potential kit inclusion
- **Enriched project registry** — `evalScore`, `evalBreakdown`, `installedModules`, `maturity`, `summary` fields

### Changed
- `registry/projects.json` schema expanded with evaluation and module tracking fields
- Onboarding is now skill-first; shell scripts (`init.sh`, `adopt.sh`, `upgrade.sh`) remain as legacy fallback

## [1.1.0] - 2026-04-08

### Added
- `known-traps.md` baseline rule — empty accumulator for platform/framework gotchas
- `pre-implementation-checklist.md` optional rule — read-before-write gate
- `design-auditor` agent template — compliance scanner with 8 audit categories
- `video-toolkit` SKILL.md — audio-first video analysis workflow
- Unknown `.claude/` file discovery with remove/keep/ignore disposition
- `init` guard — blocks on existing Claude Code files, directs to `adopt`
- `--overwrite` and `--no-discover` flags for init/adopt/upgrade
- Bi-directional `sync-memory.sh` with multi-path resolution and delete tracking
- `sync-memory.sh status` and `--dry-run` commands
- Centralized `VERSION` file and `CHANGELOG.md`
- Session-start version check via Claude Code SessionStart hook
- `check-version.sh` script — auto-detects kit updates and shows changelog diff

### Changed
- README rewritten with organized baseline/optional module documentation
- `sync-memory.sh` rewritten with merge logic (newer-file-wins, manifest-tracked deletes)
- All scripts read version from `VERSION` file instead of hardcoding

## [1.0.0] - 2026-04-07

### Added
- Initial release — baseline templates, 7 rules, 5 stack presets
- CLI with 10 commands (init, adopt, upgrade, register, new-skill, new-agent, new-rule, status, retro, version)
- Cross-project registry (projects, tools, MCPs, skills, guardrails)
- Playbook with 8 patterns and 3 learnings
- `adopt` command for integrating kit into existing projects
