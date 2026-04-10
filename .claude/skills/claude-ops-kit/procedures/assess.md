# Procedure: Assess Project

Evaluates a project's Claude Code ops setup and produces a comprehensiveness score. Used after init/adopt/upgrade and on-demand via the Evaluate path.

## What to Scan

Read the project's actual files — don't rely on `claude-ops.json` alone, as it may be stale.

### 1. Rules Coverage (0-10)

Check `.claude/rules/` for baseline and custom rules:

| Score | Criteria |
|-------|----------|
| 10 | All 8 baseline rules + stack-specific rules + 3+ custom rules tailored to the project |
| 8 | All baseline rules + stack-specific rules present |
| 6 | Most baseline rules present, some gaps |
| 4 | Partial baseline coverage, no stack-specific rules |
| 2 | Only 1-2 rules exist |
| 0 | No rules directory |

### 2. Memory Hygiene (0-10)

Check `.claude/MEMORY.md` and memory sync infrastructure:

| Score | Criteria |
|-------|----------|
| 10 | MEMORY.md actively maintained, sync-memory.sh present + memory-sync dir has recent exports, entries are organized and pruned |
| 8 | MEMORY.md exists with entries, sync infrastructure present |
| 6 | MEMORY.md exists but sparse or disorganized |
| 4 | MEMORY.md exists but empty or boilerplate only |
| 2 | Memory infrastructure partially present |
| 0 | No memory system |

### 3. Skill Usage (0-10)

Check `.claude/skills/` for defined skills:

| Score | Criteria |
|-------|----------|
| 10 | 3+ skills including handoff + at least 1 project-specific custom skill |
| 8 | Handoff + PR + 1 other skill |
| 6 | Handoff + 1 other skill |
| 4 | Only handoff skill |
| 2 | Skills directory exists but empty or malformed |
| 0 | No skills |

### 4. Agent Templates (0-10)

Check `.claude/agents/` for configured agents:

| Score | Criteria |
|-------|----------|
| 10 | 3+ agents with project-specific customizations in their CLAUDE.md |
| 8 | 2-3 agents present with meaningful instructions |
| 6 | 1-2 agents from kit templates |
| 4 | Agents directory exists with 1 minimal agent |
| 2 | Agents directory exists but empty |
| 0 | No agents |

### 5. Git Discipline (0-10)

Check git configuration and hooks:

| Score | Criteria |
|-------|----------|
| 10 | Pre-commit hooks active + hooksPath configured + .gitignore comprehensive + branch workflow evidence in git log |
| 8 | Pre-commit hooks + hooksPath + good .gitignore |
| 6 | Some hooks present, hooksPath may not be set |
| 4 | Basic .gitignore only |
| 2 | Git repo exists but no workflow infrastructure |
| 0 | Not a git repo |

### 6. Documentation Quality (0-10)

Check root documentation files:

| Score | Criteria |
|-------|----------|
| 10 | CLAUDE.md customized with real architecture + PROJECT_STATE.md current + REFERENCE_MAP.md maintained |
| 8 | CLAUDE.md customized + PROJECT_STATE.md exists |
| 6 | CLAUDE.md exists with some customization beyond template |
| 4 | CLAUDE.md exists but is mostly template boilerplate |
| 2 | Only basic CLAUDE.md |
| 0 | No CLAUDE.md |

### 7. Session Infrastructure (0-10)

Check scripts, hooks, and session workflow support:

| Score | Criteria |
|-------|----------|
| 10 | sync-memory.sh + verify-sync.sh + check-version.sh + SessionStart hook + all scripts functional |
| 8 | All scripts present + SessionStart hook configured |
| 6 | Most scripts present, hook may be missing |
| 4 | Some scripts present |
| 2 | Scripts directory exists but minimal |
| 0 | No session infrastructure |

## Calculating the Score

```
overall = (rules + memory + skills + agents + git + docs + session) / 7
```

Round to one decimal place. The overall score is out of 10.

### Maturity Labels

| Score | Label |
|-------|-------|
| 9.0+ | `gold-standard` |
| 7.0-8.9 | `well-equipped` |
| 5.0-6.9 | `functional` |
| 3.0-4.9 | `getting-started` |
| < 3.0 | `minimal` |

## Output Format

Present the evaluation conversationally:

> **Project Evaluation: {name}**
>
> | Category | Score | Notes |
> |----------|-------|-------|
> | Rules Coverage | 8/10 | All baseline + luau-conventions, missing custom project rules |
> | Memory Hygiene | 6/10 | MEMORY.md exists but hasn't been exported recently |
> | ... | ... | ... |
>
> **Overall: 7.1/10 (well-equipped)**
>
> **Quick wins to improve:**
> 1. {specific actionable suggestion}
> 2. {specific actionable suggestion}

## Registry Entry Format

After evaluation, the project entry in `registry/projects.json` should include:

```json
{
  "name": "project-name",
  "summary": "One-line description of what this project does",
  "repo": "org/repo-name",
  "stack": ["nodejs", "typescript"],
  "kitVersion": "1.2.0",
  "installedModules": ["baseline", "testing", "backlog", "code-reviewer"],
  "evalScore": 7.1,
  "evalBreakdown": {
    "rulesCoverage": 8,
    "memoryHygiene": 6,
    "skillUsage": 7,
    "agentTemplates": 5,
    "gitDiscipline": 9,
    "documentationQuality": 7,
    "sessionInfrastructure": 8
  },
  "maturity": "well-equipped",
  "lastAssessed": "2026-04-10",
  "features": {
    "backlog": true,
    "domains": false,
    "agents": ["code-reviewer"],
    "skills": ["handoff", "pr"],
    "testing": true,
    "dependencyGraph": false
  },
  "customRules": ["my-api-safety"],
  "mcps": ["playwright"]
}
```
