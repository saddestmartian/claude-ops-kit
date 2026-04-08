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

---

## Commands

### `claude-ops init`

Bootstraps a **new project** from scratch with the full Claude Code workflow infrastructure.

Walks you through an interactive setup:
- Project name and task ID prefix
- Tech stack selection (Node.js, TypeScript, Swift, Python, Luau)
- Lint/format/test commands (auto-suggested from stack)
- Optional modules (backlog, agents, skills, testing, etc.)

**Safety guard:** Blocks if it detects existing Claude Code files (CLAUDE.md, `.claude/rules/`, etc.) to prevent accidental overwrites. Use `claude-ops adopt` for existing projects instead.

| Flag | Effect |
|------|--------|
| `--overwrite` | Force init even if existing Claude Code files are found |
| `--no-discover` | Skip unknown file discovery (for CI / non-interactive use) |

### `claude-ops adopt`

Integrates the kit into an **existing project** that already has some Claude Code setup (CLAUDE.md, rules, skills, etc.) but wasn't bootstrapped by the kit.

Unlike `init` (which creates everything fresh), `adopt`:
1. **Scans** what you already have (CLAUDE.md, `.claude/rules/`, skills, scripts, etc.)
2. **Shows** what exists vs what the kit would add
3. **Per-component choice**: merge (add missing pieces), skip (keep yours), or replace
4. **Discovers unknown files** — any `.claude/` content that isn't part of the kit is surfaced for you to remove, keep (with upstream issue filed), or ignore
5. **Never overwrites** without asking — existing rules and skills are preserved
6. **Generates** `claude-ops.json` so `upgrade` works going forward

If your CLAUDE.md is missing key sections (investigation-first, anti-spiral, etc.), adopt writes a `CLAUDE.md.kit-reference` alongside your existing file for manual merge.

| Flag | Effect |
|------|--------|
| `--no-discover` | Skip unknown file discovery |

### `claude-ops upgrade`

Pulls updated templates from the kit into a project that's already managed by claude-ops.

- Compares your project's `claude-ops.json` version against the kit's `VERSION` file
- Adds new baseline rules that were introduced since your last upgrade
- Skips rules you've customized (detects user modifications)
- Updates `check-version.sh` to the latest and ensures the SessionStart hook is configured
- Discovers any new unknown `.claude/` files since the last run
- Updates the manifest version and `kitPath`

| Flag | Effect |
|------|--------|
| `--no-discover` | Skip unknown file discovery |

### Other Commands

| Command | Description |
|---------|-------------|
| `claude-ops register` | Register current project in the cross-project registry |
| `claude-ops new-skill` | Scaffold a new skill in `.claude/skills/` |
| `claude-ops new-agent` | Scaffold a new agent in `.claude/agents/` |
| `claude-ops new-rule` | Scaffold a new rule in `.claude/rules/` |
| `claude-ops status` | Show kit version, project health, and discovered files |
| `claude-ops retro` | Generate a dated retrospective template |
| `claude-ops version` | Show kit version |

---

## What Gets Created

### Baseline (Always Included)

Every `init` or `adopt` run installs these foundational files:

#### Root Files
| File | Purpose |
|------|---------|
| `CLAUDE.md` | Root instructions — workflow rules, session start checklist, critical guardrails |
| `PROJECT_STATE.md` | Session context — current status, what's done, in progress, next up |
| `REFERENCE_MAP.md` | Module inventory with line counts and roles |
| `claude-ops.json` | Kit manifest for version tracking and upgrade support |

#### Rules (`.claude/rules/`)

Auto-loaded behavioral guardrails — Claude Code reads these every session:

| Rule | File | Purpose |
|------|------|---------|
| Investigation-First | `investigation-first.md` | Read before edit. Trace the execution path. |
| Anti-Spiral | `anti-spiral.md` | Prevent fix-on-fix loops. Three whiffs = stop. |
| Git Safety | `git-safety.md` | Never silently resolve conflicts or discard changes. |
| Phase Gates | `phase-gates.md` | Report at checkpoints for multi-file changes. |
| Confidence Flagging | `confidence-flagging.md` | Mark API assumptions as VERIFIED / ASSUMED / UNVERIFIED. |
| Code Discipline | `code-discipline.md` | Surgical edits, 60-line limit, read before write. |
| Milestone Reporting | `milestone-reporting.md` | Report at natural milestones, not arbitrary intervals. |
| Workflow Feedback | `workflow-feedback.md` | Empty accumulator for project-specific learned rules. |
| Known Traps | `known-traps.md` | Empty accumulator for platform/framework-specific gotchas. |

#### Skills (`.claude/skills/`)
| Skill | Path | Purpose |
|-------|------|---------|
| Handoff | `skills/handoff/SKILL.md` | Session handoff procedure — capture state for next session |

#### Setup & Infrastructure
| File | Purpose |
|------|---------|
| `.claude/setup/macos.md` | macOS platform setup checklist |
| `.claude/setup/windows.md` | Windows platform setup checklist |
| `.claude/setup/cloud.md` | Cloud environment setup checklist |
| `.claude/MEMORY.md` | Memory index for cross-session persistence |
| `.claude/memory-sync/` | Directory for git-tracked memory backup |
| `.githooks/pre-commit` | Format + lint gates (auto-configured via `core.hooksPath`) |
| `scripts/sync-memory.sh` | Cross-machine memory sync script |
| `scripts/verify-sync.sh` | Memory drift detection diagnostic |
| `scripts/check-version.sh` | Session-start kit version check |
| `.claude/settings.json` | Claude Code hooks (SessionStart version check) |

### Optional Modules

Selected during `init` or detected during `adopt`:

#### Agents (`.claude/agents/`)
| Agent | Path | Purpose |
|-------|------|---------|
| Architecture Validator | `agents/architecture-validator/` | Dead code detection, REFERENCE_MAP alignment, test coverage gaps, dependency health |
| Design Advisor | `agents/design-advisor/` | UX/design consultation for layout, color, accessibility |
| Design Auditor | `agents/design-auditor/` | Compliance scanner — audits code against design system tokens, responsive rules, CTA hierarchy |
| Code Reviewer | `agents/code-reviewer/` | PR-level code review — correctness, security, style, tests |

#### Skills (`.claude/skills/`)
| Skill | Path | Purpose |
|-------|------|---------|
| PR | `skills/pr/` | Pre-validation (lint, test, sync) before PR creation |
| Video Toolkit | `skills/video-toolkit/` | FFmpeg + Whisper video analysis (audio-first workflow, frame extraction, cursor tracking) |

#### Rules (`.claude/rules/`)
| Rule | File | Purpose |
|------|------|---------|
| Testing Framework | `testing-requirements.md` | Decision tree for when tests are required + coverage enforcement |
| Pre-Implementation Checklist | `pre-implementation-checklist.md` | Read-before-write gate — read targets, trace deps, confirm approach |
| Codebase Audit | `audit-protocol.md` | Parallel sub-agent audit protocol |

#### Project Files
| Module | File | Purpose |
|--------|------|---------|
| Backlog System | `backlog.json` + `backlog-viewer.html` | JSON task registry with HTML kanban viewer |
| Domain Model | `DOMAINS.md` | Lightweight DDD bounded contexts |
| Retrospectives | `.claude/retrospectives/retro-template.md` | Session retrospective template |

---

## Unknown File Discovery

All three commands (`init --overwrite`, `adopt`, `upgrade`) scan `.claude/` for files that aren't part of the kit. This catches custom rules, skills, agents, or other artifacts you've created independently.

For each unknown file, you choose:
- **Remove** — Delete the file
- **Keep** — Preserve it, catalogue it in `claude-ops.json`, and file a GitHub issue on the kit repo suggesting it for inclusion
- **Ignore** — Acknowledge it exists, catalogue it, no upstream action

Previously catalogued items (keep/ignore) are not re-prompted on subsequent runs. Removed items are re-prompted if the file reappears.

Claude Code native files (`.claude/settings.json`, `.claude/settings.local.json`, `.claude/worktrees/`) are silently skipped — they're managed by Claude Code itself.

Use `--no-discover` on any command to skip discovery entirely.

---

## Automatic Version Check

When you start a Claude Code session in a kit-managed project, a SessionStart hook runs `scripts/check-version.sh`. If your project's kit version is behind the installed kit, you'll see:

```
⚠ claude-ops-kit update available: 1.0.0 → 1.1.0

Changes since 1.0.0:
## [1.1.0] - 2026-04-08
### Added
- known-traps.md baseline rule...
[changelog entries]

Run 'claude-ops upgrade' to update.
```

The check resolves the kit version via:
1. `kitPath` stored in `claude-ops.json` (set during init/adopt/upgrade)
2. Fallback: `claude-ops` on PATH (follows symlink to kit root)
3. Fallback: GitHub API via `gh` (for remote-only workflows)

If none resolve, the check exits silently — no noise, no errors.

---

## Stack Presets

Pre-configured lint/format commands and language-specific convention rules:

| Stack | Lint | Format | Convention Rules |
|-------|------|--------|-----------------|
| Node.js | `npx eslint .` | `npx prettier --check .` | npm safety, async patterns |
| TypeScript | `npx eslint .` | `npx prettier --check .` | strict mode, type safety |
| Swift | `swiftlint` | `swiftformat --lint .` | SwiftUI patterns, concurrency |
| Python | `ruff check .` | `ruff format --check .` | venv, type hints, pathlib |
| Luau | `selene src/` | `stylua --check src/` | Roblox API safety, Studio limitations |

---

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

## Multi-Platform Support

Works across:
- **Claude Code CLI** (local terminal)
- **Claude Code Desktop** (Mac/Windows app)
- **claude.ai/code** (cloud/mobile)
- **macOS** and **Windows** (Git Bash)

Memory sync, session handoff, and platform setup checklists handle the differences.

## License

MIT
