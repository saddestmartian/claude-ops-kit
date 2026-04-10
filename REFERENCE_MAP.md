# Reference Map — claude-ops-kit

Module inventory for this repository. Updated when modules are added, removed, or renamed.

## Core

| Path | Role | Lines |
|------|------|-------|
| `CLAUDE.md` | Root instructions for working in this repo | ~95 |
| `CHANGELOG.md` | Version history | ~55 |
| `VERSION` | Semver version file | 1 |
| `README.md` | Public documentation | ~varies |

## Templates — Baseline

| Path | Role |
|------|------|
| `templates/baseline/CLAUDE.md.tmpl` | Root instructions template |
| `templates/baseline/PROJECT_STATE.md.tmpl` | Session context template |
| `templates/baseline/REFERENCE_MAP.md.tmpl` | Module inventory template |
| `templates/baseline/AGENTS.md.tmpl` | Cross-tool agent instructions |
| `templates/baseline/claude/MEMORY.md.tmpl` | Memory index template |
| `templates/baseline/claude/rules/` | 9 baseline rule files |
| `templates/baseline/claude/setup/` | 3 platform setup templates |
| `templates/baseline/claude/skills/handoff/` | Session handoff skill |
| `templates/baseline/claude/skills/claude-ops-kit/` | Onboarding skill + 6 procedures |
| `templates/baseline/githooks/pre-commit.tmpl` | Pre-commit hook template |
| `templates/baseline/scripts/` | sync-memory, verify-sync, check-version |

## Templates — Optional

| Path | Role |
|------|------|
| `templates/optional/agents/` | 4 agent templates (arch-validator, code-reviewer, design-advisor, design-auditor) |
| `templates/optional/backlog/` | Backlog system (JSON + HTML viewer) |
| `templates/optional/skills/` | PR skill, video-toolkit skill |
| `templates/optional/testing/` | Testing requirements + pre-impl checklist |
| `templates/optional/codebase-audit/` | Audit protocol |
| `templates/optional/domains/` | DDD domain model template |
| `templates/optional/retrospective/` | Retro template |

## Templates — Stack Presets

| Path | Stack |
|------|-------|
| `templates/stack-presets/nodejs/` | Node.js rules + pre-commit |
| `templates/stack-presets/typescript/` | TypeScript rules + pre-commit |
| `templates/stack-presets/python/` | Python rules + pre-commit |
| `templates/stack-presets/swift/` | Swift rules + pre-commit |
| `templates/stack-presets/luau/` | Luau rules + pre-commit |

## Registry

| Path | Role |
|------|------|
| `registry/projects.json` | Cross-project inventory with eval scores |
| `registry/tools.json` | Tool inventory |
| `registry/mcps.json` | MCP server inventory |
| `registry/skills.json` | Skill inventory |
| `registry/guardrails.json` | Guardrail inventory |
| `registry/contributions/` | Inbound contribution manifests |

## Scripts

| Path | Role |
|------|------|
| `scripts/init.sh` | Legacy CLI init (shell-driven) |
| `scripts/adopt.sh` | Legacy CLI adopt |
| `scripts/upgrade.sh` | Legacy CLI upgrade |
| `scripts/register.sh` | Register a project in registry |
| `scripts/new-agent.sh` | Scaffold a new agent template |
| `scripts/new-rule.sh` | Scaffold a new rule |
| `scripts/new-skill.sh` | Scaffold a new skill |
| `scripts/status.sh` | Show kit status |
| `scripts/retro.sh` | Start a retrospective |
| `scripts/check-drift.sh` | Compare installed rules vs templates (self-hosting) |
| `scripts/lib/discovery.sh` | Shared discovery library |

## Playbook

| Path | Role |
|------|------|
| `playbook/patterns/` | 8 workflow pattern docs |
| `playbook/learnings/` | 4 learning docs (trust erosion, compaction, cross-platform, constraint budget) |
| `playbook/retrospectives/` | Session retros |
