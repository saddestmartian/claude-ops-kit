# Changelog

All notable changes to claude-ops-kit are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/).

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
