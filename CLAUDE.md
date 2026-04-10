# claude-ops-kit — Claude Code Instructions

> Project-agnostic bootstrap framework for Claude Code workflows. This repo IS the kit — it contains templates, registry, playbook, and CLI tools.

## What This Repo Is

A toolkit for initializing and managing Claude Code workflows across multiple projects. It extracts battle-tested patterns from 82+ sessions into reusable templates.

### Three Purposes
1. **Bootstrap kit** — The `/claude-ops-kit` skill onboards any project via conversational setup (init, adopt, upgrade)
2. **Cross-project registry** — Tracks projects, tools, MCPs, skills, evaluations, and contributions
3. **Living playbook** — Captures evolving patterns and learnings

## Repository Structure

```
templates/baseline/     — Always-installed files (CLAUDE.md.tmpl, rules, scripts, setup)
templates/baseline/claude/skills/claude-ops-kit/ — The onboarding skill + procedure docs
templates/optional/     — User-selected modules (backlog, agents, skills, testing)
templates/stack-presets/ — Language-specific rules and tool configs
registry/               — Cross-project inventory (projects, tools, MCPs, skills, guardrails)
registry/contributions/ — Inbound contribution manifests from user projects
playbook/               — Narrative docs explaining patterns and learnings
bin/                    — CLI entry points (claude-ops, install.sh)
scripts/                — Init, upgrade, scaffolding automation (legacy — skill is primary)
```

## Template System

### Variables
Files ending in `.tmpl` use `{{VARIABLE}}` substitution. The `init.sh` script replaces these with user-provided values during bootstrap.

| Variable | Description | Example |
|----------|-------------|---------|
| `{{PROJECT_NAME}}` | Project name | `my-app` |
| `{{PROJECT_DESCRIPTION}}` | One-line description | `A Discord bot` |
| `{{TASK_PREFIX}}` | Task ID prefix | `MYA` |
| `{{TECH_STACK}}` | Primary tech stack | `nodejs` |
| `{{GITHUB_ORG}}` | GitHub org/user | `saddestmartian` |
| `{{SOURCE_DIR}}` | Source code directory | `src/` |
| `{{FILE_EXTENSION}}` | Primary file extension | `.ts` |
| `{{LINT_CMD}}` | Lint command | `npx eslint .` |
| `{{FORMAT_CMD}}` | Format command | `npx prettier --check .` |
| `{{TEST_CMD}}` | Test command | `npm test` |
| `{{DATE}}` | Current date | `2026-04-08` |
| `{{KIT_VERSION}}` | Kit version | `1.0.0` |

### Non-template files
Files without `.tmpl` extension are copied verbatim (e.g., `sync-memory.sh`, rule files).

## Onboarding Architecture

The primary onboarding mechanism is the `/claude-ops-kit` skill. Users invoke it from their project and it handles everything conversationally.

### Skill Router
`templates/baseline/claude/skills/claude-ops-kit/SKILL.md` — single entry point that auto-detects project state (no kit, existing setup, outdated version, up-to-date) and routes to the correct procedure.

### Procedure Docs
`templates/baseline/claude/skills/claude-ops-kit/procedures/` — modular reference docs:
- `assess.md` — 7-category evaluation rubric with scoring
- `init.md` — full init for empty/new repos
- `adopt.md` — intelligent merge for repos with existing Claude Code setup
- `upgrade.md` — version-aware selective upgrade
- `evaluate.md` — on-demand project comprehensiveness scoring
- `contribute.md` — catalog user patterns for potential kit inclusion

### Legacy Shell Scripts
`scripts/init.sh`, `adopt.sh`, `upgrade.sh` remain as fallback for users who prefer CLI-driven setup. The skill is the recommended path.

### Inbound Contributions
When users share patterns back via the contribute flow, manifests are saved to `registry/contributions/`. When working in this repo, assess pending contributions and triage into baseline-worthy, optional-worthy, snippet-merge, or abstain.

## Working in This Repo

### Adding a New Pattern
1. Write the pattern doc in `playbook/patterns/`
2. If it should be auto-loaded as a rule, also create a terse version in `templates/baseline/claude/rules/`
3. Update `playbook/README.md` index

### Adding a New Stack Preset
1. Create `templates/stack-presets/<stack>/rules/<name>.md`
2. Create `templates/stack-presets/<stack>/pre-commit-config.json`

### Adding a New Optional Module
1. Create template files in `templates/optional/<module>/`
2. Document the module in `procedures/init.md` Available Modules table

### Updating the Onboarding Skill
1. The SKILL.md router should stay concise — it routes, it doesn't contain procedures
2. Procedure docs are the right place for detailed logic
3. Test changes by running `/claude-ops-kit` in a test project

### Updating the Registry
Edit JSON files in `registry/` directly. The `projects.json` schema includes:
- `evalScore` / `evalBreakdown` — from the 7-category rubric in `procedures/assess.md`
- `installedModules` — which kit modules are active
- `maturity` — derived from eval score (gold-standard, well-equipped, functional, getting-started, minimal)

### Processing Contributions
When contribution manifests exist in `registry/contributions/`:
1. Read each manifest and the referenced source files
2. Triage each contribution (baseline / optional / snippet / abstain)
3. Apply accepted contributions to the appropriate template files
4. Update CHANGELOG and bump VERSION
5. Only bump major version for structural changes to baseline fileset

## Do Not
- Add project-specific code to this repo (it's a meta-tool)
- Modify templates without testing the onboarding skill in a fresh directory
- Remove baseline rules without understanding why they exist (read the playbook entry first)
- Put procedure logic directly in SKILL.md — it belongs in procedure docs
