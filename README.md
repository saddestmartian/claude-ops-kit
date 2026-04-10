# claude-ops-kit

A project-agnostic bootstrap framework for Claude Code workflows. Initialize any new repo with battle-tested guardrails, session management, memory sync, and task tracking — extracted from 82+ sessions of production development.

## Quick Start

### Option 1: Skill-Driven (Recommended)

The kit onboards your project through a conversation — Claude reads your existing setup, recommends what fits, and intelligently merges. No shell prompts, no yes/no/keep/merge.

```bash
# 1. Clone the kit
git clone https://github.com/saddestmartian/claude-ops-kit.git

# 2. Seed the onboarding skill into your project
cd /path/to/your/project
bash /path/to/claude-ops-kit/bin/seed.sh

# 3. Open Claude Code and run the skill
/claude-ops-kit
```

Claude will auto-detect whether your project needs a fresh init, an adopt/merge, or an upgrade — and walk you through it.

#### Install Globally (available in every project)

If you want `/claude-ops-kit` available in all your projects without seeding each one:

```bash
mkdir -p ~/.claude/skills
cp -r /path/to/claude-ops-kit/templates/baseline/claude/skills/claude-ops-kit ~/.claude/skills/
```

### Option 2: CLI-Driven (Legacy)

Shell-script-driven setup with interactive prompts. Still works, but the skill-driven approach is more intelligent about merging and recommendations.

```bash
# 1. Clone the kit
git clone https://github.com/saddestmartian/claude-ops-kit.git
cd claude-ops-kit

# 2. Install the CLI
bash bin/install.sh

# 3. Initialize a project
cd /path/to/your/project
claude-ops init     # new project
claude-ops adopt    # existing project with Claude Code files
claude-ops upgrade  # already kit-managed, pull updates
```

---

## How `/claude-ops-kit` Works

The skill is a single entry point. It assesses your project and routes automatically:

```
Is claude-ops-kit installed?
├── NO → Is the repo empty?
│   ├── YES → Full init (assess stack, recommend modules, generate)
│   └── NO  → Adopt/merge (map existing files, intelligently merge)
│
└── YES → Compare versions
    ├── Outdated → Show changes, walk through selective upgrade
    └── Current  → Offer evaluate, contribute, or re-assess
```

### Complexity Profiles

The skill recommends a profile based on your project signals, but **you always choose**:

| Profile | Rules | Best For |
|---------|-------|----------|
| **Solo** | 4 core rules | Single-developer, fast iteration |
| **Team** | All 8 baseline rules + PR automation | Collaborative projects, vibecoders who want strong guardrails |
| **Enterprise** | All rules + hooks-enforced gates + audit trail | Compliance, large teams, required reviews |

### Contribution Pipeline

The skill also handles sharing your patterns back to the kit. Custom rules, skills, and learnings from your project can be cataloged, triaged, and fed upstream.

---

## CLI Commands (Legacy)

These shell-script commands remain available as an alternative to the skill:

| Command | Description |
|---------|-------------|
| `claude-ops init` | Bootstrap a new project (interactive prompts) |
| `claude-ops adopt` | Integrate kit into existing project |
| `claude-ops upgrade` | Pull updated templates |
| `claude-ops register` | Register project in cross-project registry |
| `claude-ops new-skill` | Scaffold a new skill |
| `claude-ops new-agent` | Scaffold a new agent |
| `claude-ops new-rule` | Scaffold a new rule |
| `claude-ops status` | Show kit version and project health |
| `claude-ops retro` | Generate a retrospective template |
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
