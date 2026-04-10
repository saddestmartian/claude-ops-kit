# Procedure: Initialize New Project

Full claude-ops-kit setup for an empty or near-empty repository. This procedure replaces the interactive shell prompts of `scripts/init.sh` with an intelligent, conversational onboarding.

## Prerequisites
- `KIT_ROOT` is resolved (the skill router did this)
- `KIT_VERSION` is known
- `COMPLEXITY_PROFILE` is determined (solo/team/enterprise)
- The target project has no existing `claude-ops.json`

## Phase 1: Gather Project Context

Assess the project directory to auto-detect what you can:

```bash
# Project name from directory
basename "$(pwd)"

# Git remote for org detection
git remote get-url origin 2>/dev/null

# Detect tech stack from files present
ls package.json tsconfig.json Cargo.toml pyproject.toml *.xcodeproj *.luau 2>/dev/null
```

Then have a conversation with the user to confirm and fill gaps. Don't present a form — talk through it naturally:

> "I see this is **{name}** — a {detected_stack} project under **{org}**. What does this project do in a sentence?"

Collect these values through conversation (auto-detect where possible, ask only what's missing):

| Value | Auto-detect From | Ask If |
|-------|-----------------|--------|
| `PROJECT_NAME` | Directory name | Never (confirm if unusual) |
| `PROJECT_DESCRIPTION` | README.md first line, package.json description | Always — one sentence |
| `TASK_PREFIX` | First 3 chars of name, uppercased | Confirm default |
| `TECH_STACK` | File detection (package.json=nodejs, tsconfig=typescript, etc.) | Confirm detected |
| `GITHUB_ORG` | Git remote URL | If no remote |
| `SOURCE_DIR` | Common patterns (src/, lib/, app/) | If ambiguous |
| `FILE_EXTENSION` | Stack implies it (.ts, .py, .swift, .luau, .js) | Never |
| `LINT_CMD` | Stack implies defaults | Confirm or customize |
| `FORMAT_CMD` | Stack implies defaults | Confirm or customize |
| `TEST_CMD` | Stack implies defaults | Confirm or customize |

### Stack Defaults

| Stack | Lint | Format | Test |
|-------|------|--------|------|
| typescript/nodejs | `npx eslint .` | `npx prettier --check .` | `npm test` |
| swift | `swiftlint` | `swiftformat --lint .` | `swift test` |
| python | `ruff check .` | `ruff format --check .` | `pytest` |
| luau | `selene src/` | `stylua --check src/` | `echo 'Tests run via Roblox Studio playtest'` |

## Phase 2: Recommend Modules

Based on what you've learned about the project, recommend optional modules. Don't present a checklist — explain why each recommendation makes sense:

> "Since this is a TypeScript API service, I'd recommend:
> - **Testing framework** — you have Jest configured, so the testing rules will integrate well
> - **Code reviewer agent** — useful for solo projects to get a second pair of eyes
> - **PR skill** — automates lint/test gates before PR creation
>
> I'd skip the video toolkit and design auditor since they don't fit this project type.
>
> Want all of these, or want to adjust?"

### Available Optional Modules

| Module | Template Source | Good For |
|--------|---------------|----------|
| Backlog system | `optional/backlog/` | Any project with task tracking needs |
| Domain model | `optional/domains/` | Projects with complex business logic (DDD) |
| Architecture validator | `optional/agents/architecture-validator/` | Multi-module projects with architectural constraints |
| Design advisor | `optional/agents/design-advisor/` | UI/UX projects |
| Design auditor | `optional/agents/design-auditor/` | Projects with compliance/design system requirements |
| Code reviewer | `optional/agents/code-reviewer/` | Solo devs or small teams wanting automated review |
| PR skill | `optional/skills/pr/` | Any project using GitHub PRs |
| Video toolkit | `optional/skills/video-toolkit/` | Projects involving media/video processing |
| Testing framework | `optional/testing/` | Projects with test suites |
| Pre-impl checklist | `optional/testing/pre-implementation-checklist.md` | Complex codebases where read-before-write matters |
| Codebase audit | `optional/codebase-audit/` | Large or inherited codebases |
| Retrospective | `optional/retrospective/` | Teams doing regular retros |

## Phase 3: Generate Files

Once the user confirms, generate all files. Use the kit's templates as source, performing `{{VARIABLE}}` substitution.

### Template Rendering

For each `.tmpl` file, replace all `{{VARIABLE}}` placeholders with the collected values. For non-template files (plain `.md`, `.sh`), copy verbatim.

### File Generation Order

**Always generate (baseline):**

1. **Directories first:**
   - `.claude/rules/`
   - `.claude/skills/handoff/`
   - `.claude/skills/claude-ops-kit/` (this skill itself)
   - `.claude/setup/`
   - `.claude/memory-sync/`
   - `.githooks/`
   - `scripts/`

2. **Root documents** (render from templates):
   - `CLAUDE.md` from `templates/baseline/CLAUDE.md.tmpl`
   - `PROJECT_STATE.md` from `templates/baseline/PROJECT_STATE.md.tmpl`
   - `REFERENCE_MAP.md` from `templates/baseline/REFERENCE_MAP.md.tmpl`

3. **Claude Code internals:**
   - `.claude/MEMORY.md` from `templates/baseline/claude/MEMORY.md.tmpl`
   - **Rules (profile-aware):**
     - **Solo:** anti-spiral, code-discipline, investigation-first, confidence-flagging, known-traps, workflow-feedback (6 rules)
     - **Team:** all 8 baseline rules + workflow-feedback + known-traps
     - **Enterprise:** all 8 baseline rules + workflow-feedback + known-traps
   - Stack-specific rules from `templates/stack-presets/{stack}/rules/` (all profiles)
   - Override protocol rule: `override-protocol.md` (all profiles — but solo uses lightweight version)
   - Setup guides from `templates/baseline/claude/setup/` (render templates)
   - Handoff skill from `templates/baseline/claude/skills/handoff/SKILL.md.tmpl` (render)
   - This skill: copy `templates/baseline/claude/skills/claude-ops-kit/` directory (verbatim)

4. **Git infrastructure:**
   - `.githooks/pre-commit` from `templates/baseline/githooks/pre-commit.tmpl` (render)
   - Append to `.gitignore`: `.claude/worktrees/`, `.env`, `node_modules/`, `.claude/settings.local.json`

5. **Scripts** (copy verbatim):
   - `scripts/sync-memory.sh`
   - `scripts/check-version.sh`
   - `scripts/verify-sync.sh` from template (render)

6. **Settings:**
   - `.claude/settings.json` with SessionStart hook for version check

7. **Accumulators** (create empty):
   - `.claude/rules/workflow-feedback.md`

**Conditionally generate (optional modules):**
Generate only what the user selected. Follow the same render-or-copy logic.

## Phase 4: Generate Manifest

Create `claude-ops.json` in the project root:

```json
{
  "version": "{KIT_VERSION}",
  "kitRepo": "saddestmartian/claude-ops-kit",
  "profile": "{COMPLEXITY_PROFILE}",
  "project": {
    "name": "{PROJECT_NAME}",
    "summary": "{PROJECT_DESCRIPTION}",
    "repo": "{GITHUB_ORG}/{PROJECT_NAME}",
    "stack": ["{TECH_STACK}"],
    "taskPrefix": "{TASK_PREFIX}",
    "sourceDir": "{SOURCE_DIR}",
    "fileExtension": "{FILE_EXTENSION}"
  },
  "tools": {
    "lint": "{LINT_CMD}",
    "format": "{FORMAT_CMD}",
    "test": "{TEST_CMD}"
  },
  "features": {
    "backlog": false,
    "domains": false,
    "agents": [],
    "skills": ["handoff", "claude-ops-kit"],
    "testing": false,
    "dependencyGraph": false
  },
  "lastUpgrade": "{TODAY}"
}
```

Update the `features` object based on what was actually installed.

### AGENTS.md Generation (Team and Enterprise profiles)

For Team and Enterprise profiles, also generate an `AGENTS.md` file in the project root for cross-tool compatibility (Codex, Copilot, Cursor, Windsurf, etc.). Render from `templates/baseline/AGENTS.md.tmpl`.

Solo profile: skip AGENTS.md unless the user requests it.

## Phase 5: Configure Git

```bash
git config core.hooksPath .githooks
```

## Phase 6: Summary

Present what was created conversationally:

> "All set. Here's what I've put in place for **{name}**:
>
> - **CLAUDE.md** — root instructions tailored to your {stack} project
> - **8 baseline rules** + {stack} conventions in `.claude/rules/`
> - **Handoff skill** for session continuity
> - {list of optional modules installed}
> - **Pre-commit hooks** for lint/format gating
> - **Session infrastructure** — memory sync, version check, drift detection
>
> **Recommended next steps:**
> 1. Review `CLAUDE.md` and fill in the Architecture section
> 2. Start a Claude Code session — the kit will load automatically
> 3. Run `/handoff` at the end of your first session to test the workflow"

Do NOT present this as a wall of file paths. Focus on what the user gets, not what files exist.
