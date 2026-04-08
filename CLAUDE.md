# claude-ops-kit — Claude Code Instructions

> Project-agnostic bootstrap framework for Claude Code workflows. This repo IS the kit — it contains templates, registry, playbook, and CLI tools.

## What This Repo Is

A toolkit for initializing and managing Claude Code workflows across multiple projects. It extracts battle-tested patterns from 82+ sessions into reusable templates.

### Three Purposes
1. **Bootstrap kit** — `claude-ops init` initializes any new repo with workflow infrastructure
2. **Cross-project registry** — Tracks tools, MCPs, skills, and guardrails across all projects
3. **Living playbook** — Captures evolving patterns and learnings

## Repository Structure

```
templates/baseline/     — Always-installed files (CLAUDE.md.tmpl, rules, scripts, setup)
templates/optional/     — User-selected modules (backlog, agents, skills, testing)
templates/stack-presets/ — Language-specific rules and tool configs
registry/               — Cross-project inventory (projects, tools, MCPs, skills, guardrails)
playbook/               — Narrative docs explaining patterns and learnings
bin/                    — CLI entry points (claude-ops, install.sh)
scripts/                — Init, upgrade, scaffolding automation
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

## Working in This Repo

### Adding a New Pattern
1. Write the pattern doc in `playbook/patterns/`
2. If it should be auto-loaded as a rule, also create a terse version in `templates/baseline/claude/rules/`
3. Update `playbook/README.md` index

### Adding a New Stack Preset
1. Create `templates/stack-presets/<stack>/rules/<name>.md`
2. Create `templates/stack-presets/<stack>/pre-commit-config.json`
3. Update `init.sh` stack detection if needed

### Adding a New Optional Module
1. Create template files in `templates/optional/<module>/`
2. Add the module to `init.sh` Phase 3 (feature selection) and Phase 5 (file generation)
3. Add to `claude-ops.json` schema features

### Updating the Registry
Edit JSON files in `registry/` directly. They're the source of truth for cross-project inventory.

## Do Not
- Add project-specific code to this repo (it's a meta-tool)
- Modify templates without testing `claude-ops init` in a fresh directory
- Remove baseline rules without understanding why they exist (read the playbook entry first)
