# claude-ops-kit

A project-agnostic bootstrap framework for Claude Code workflows. Initialize any new repo with battle-tested guardrails, session management, memory sync, and task tracking — extracted from 82+ sessions of production development.

## Quick Start

```bash
# 1. Clone the kit
git clone https://github.com/saddestmartian/claude-ops-kit.git
cd claude-ops-kit

# 2. Install the CLI
bash bin/install.sh

# 3. Initialize a project
cd /path/to/your/project
claude-ops init
```

The `init` command walks you through an interactive setup:
- Project name and task ID prefix
- Tech stack selection (Node.js, TypeScript, Swift, Python, Luau)
- Lint/format/test commands (auto-suggested from stack)
- Optional modules (backlog, agents, skills, testing, etc.)

## What Gets Created

### Always Included (Baseline)
| File | Purpose |
|------|---------|
| `CLAUDE.md` | Root instructions — workflow rules, session start, critical guardrails |
| `PROJECT_STATE.md` | Session context — what's done, in progress, next up |
| `REFERENCE_MAP.md` | Module inventory with line counts and roles |
| `.claude/rules/` | 7 auto-loaded behavioral guardrails |
| `.claude/setup/` | Per-platform setup checklists (macOS, Windows, Cloud) |
| `.claude/skills/handoff/` | Session handoff procedure |
| `.claude/MEMORY.md` | Memory index for cross-session persistence |
| `.githooks/pre-commit` | Format + lint gates |
| `scripts/sync-memory.sh` | Cross-machine memory sync |
| `scripts/verify-sync.sh` | Drift detection diagnostic |
| `claude-ops.json` | Kit manifest for version tracking |

### Optional Modules
| Module | Description |
|--------|-------------|
| Backlog system | JSON task registry + HTML kanban viewer |
| Domain model | Lightweight DDD bounded contexts |
| Architecture validator | Agent that checks dead code, drift, test gaps |
| Design advisor | Agent for UX/design consultation |
| Code reviewer | Agent for PR-level code review |
| PR skill | Pre-validation (lint, test, sync) before PR creation |
| Video toolkit | FFmpeg + Whisper video analysis |
| Testing framework | Decision tree + coverage enforcement |
| Dependency graph | Import/require graph generator |
| Codebase audit | Parallel sub-agent audit protocol |
| Retrospectives | Session retrospective template |

## The 7 Baseline Rules

These auto-load in every Claude Code session:

1. **Investigation-First** — Read before edit. Trace the execution path.
2. **Anti-Spiral** — Prevent fix-on-fix loops. Three whiffs = stop.
3. **Git Safety** — Never silently resolve conflicts or discard changes.
4. **Phase Gates** — Report at checkpoints for multi-file changes.
5. **Confidence Flagging** — Mark API assumptions as VERIFIED/ASSUMED/UNVERIFIED.
6. **Code Discipline** — Surgical edits, 60-line limit, read before write.
7. **Milestone Reporting** — Report at natural milestones, not arbitrary intervals.

## Cross-Project Registry

The `registry/` directory tracks tools, MCPs, skills, and guardrails across all your projects:

```
registry/
├── projects.json    — All registered projects with metadata
├── tools.json       — Cross-project tool inventory (gh, ffmpeg, jq, etc.)
├── mcps.json        — MCP server catalog with per-project usage
├── skills.json      — Skill catalog (baseline, optional, custom)
└── guardrails.json  — Rule catalog with per-project usage
```

## Playbook

The `playbook/` directory contains narrative documentation of workflow patterns:

- **Investigation-First** — Why read-only first actions prevent cascading mistakes
- **Anti-Spiral** — Six rules for preventing common failure modes
- **Session Workflow** — Full session lifecycle from start to handoff
- **Memory Sync** — Cross-machine memory strategy
- **Model Routing** — When to use Opus vs Sonnet
- **Sub-Agent Orchestration** — Parallel worktree agent patterns
- **Trust Erosion Patterns** — Actions that break user trust

## Stack Presets

Pre-configured lint/format commands and language-specific rules:

| Stack | Lint | Format | Convention Rules |
|-------|------|--------|-----------------|
| Node.js | `npx eslint .` | `npx prettier --check .` | npm safety, async patterns |
| TypeScript | `npx eslint .` | `npx prettier --check .` | strict mode, type safety |
| Swift | `swiftlint` | `swiftformat --lint .` | SwiftUI patterns, concurrency |
| Python | `ruff check .` | `ruff format --check .` | venv, type hints, pathlib |
| Luau | `selene src/` | `stylua --check src/` | Roblox API safety, Studio limitations |

## Adopting an Existing Project

For projects that already have some Claude Code setup (CLAUDE.md, rules, etc.) but weren't bootstrapped by the kit:

```bash
cd /path/to/existing/project
claude-ops adopt
```

Unlike `init` (which creates everything fresh), `adopt`:
1. **Scans** what you already have (CLAUDE.md, .claude/rules/, skills, scripts, etc.)
2. **Shows** what exists vs what the kit would add
3. **Per-component choice**: merge (add missing pieces), skip (keep yours), or replace
4. **Never overwrites** without asking — existing rules and skills are preserved
5. **Generates** `claude-ops.json` so `upgrade` works going forward

If your CLAUDE.md is missing key sections (investigation-first, anti-spiral, etc.), adopt writes a `CLAUDE.md.kit-reference` alongside your existing file for manual merge.

## Upgrading

```bash
cd /path/to/your/project
claude-ops upgrade
```

Compares your project's `claude-ops.json` version against the kit, applies template updates that you haven't customized, and flags conflicts for manual resolution.

## Multi-Platform Support

Works across:
- **Claude Code CLI** (local terminal)
- **Claude Code Desktop** (Mac/Windows app)
- **claude.ai/code** (cloud/mobile)
- **macOS** and **Windows** (Git Bash)

Memory sync, session handoff, and platform setup checklists handle the differences.

## License

MIT
