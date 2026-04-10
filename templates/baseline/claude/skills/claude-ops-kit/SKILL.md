# Skill: Claude Ops Kit (`/claude-ops-kit`)

## When to Use
User wants to onboard a project to claude-ops-kit, upgrade an existing installation, or contribute patterns back to the kit.

This is the single entry point for all kit interactions. The skill assesses the environment and routes to the correct procedure.

## Procedure

### Step 1: Locate the Kit

Determine where the claude-ops-kit source lives. Check in order:
1. If `claude-ops.json` exists in the current project, read `kitRepo` and `kitPath` from it
2. Check if the current directory IS the kit repo (look for `templates/baseline/` and `VERSION`)
3. Ask the user where their clone of `saddestmartian/claude-ops-kit` lives

If the kit source cannot be found, tell the user:
> To get started, clone the kit: `git clone https://github.com/saddestmartian/claude-ops-kit.git`
> Then run `/claude-ops-kit` again from your project directory.

Store the resolved kit path as `KIT_ROOT` for all subsequent steps.

### Step 2: Read Kit Version

```bash
cat "$KIT_ROOT/VERSION"
```

Store this as `KIT_VERSION`.

### Step 3: Assess the Environment

Check the current project directory for these indicators:

| Check | How | Meaning |
|-------|-----|---------|
| `claude-ops.json` exists | `test -f claude-ops.json` | Kit is already installed |
| `.claude/` directory exists | `test -d .claude` | Some Claude Code setup present |
| `CLAUDE.md` exists | `test -f CLAUDE.md` | Has root instructions |
| Repo is empty | `git log --oneline -1` fails or only has init commit | Brand new project |
| Repo has code | Source files exist beyond config | Established project |

### Step 3.5: Determine Complexity Profile

Assess which profile fits the project. This affects how many rules, modules, and gates are installed.

| Signal | Solo | Team | Enterprise |
|--------|------|------|------------|
| Contributors | 1 | 2-10 | 10+ or compliance requirements |
| Git remote collaborators | Just the user | Multiple pushers | Protected branches, required reviews |
| CI/CD present | No or basic | Yes | Yes + approval gates |
| Existing PR workflow | Informal | Standard | Gated with required checks |
| Compliance/audit needs | No | Rare | Yes |

Auto-detect from:
- `git shortlog -sn --all` — contributor count
- `.github/workflows/` or CI config presence
- Branch protection (if `gh` available: `gh api repos/{owner}/{repo}/branches/main/protection`)
- Presence of compliance-related files (LICENSE, SECURITY.md, CODEOWNERS)

Confirm with the user:

> "This looks like a **{detected}** project — {reasoning}. The kit scales its complexity to match:
> - **Solo** — minimal rules, maximum model freedom, fast iteration
> - **Team** — full baseline rules + PR automation + coordination patterns
> - **Enterprise** — full baseline + audit trail + approval gates + compliance hooks
>
> Does **{detected}** sound right?"

Store as `COMPLEXITY_PROFILE` (solo/team/enterprise) for use by procedures.

#### What Changes Per Profile

**Solo profile:**
- Baseline rules: anti-spiral, code-discipline, investigation-first, confidence-flagging (4 rules)
- Skip: phase-gates, milestone-reporting (solo dev doesn't need self-reporting)
- Git-safety loaded but relaxed (force-push allowed with confirmation, amend freely)
- No PR skill by default, no code-reviewer agent
- Override protocol: lightweight, no expiry tracking

**Team profile:**
- All 8 baseline rules active
- PR skill recommended
- Code-reviewer agent recommended
- Override protocol with rationale + expiry
- AGENTS.md generated for cross-tool compatibility

**Enterprise profile:**
- All 8 baseline rules active
- All gate rules enforced via hooks where possible (move to `settings.json`)
- PR skill + code-reviewer + architecture-validator recommended
- Override protocol with rationale + expiry + logged to registry
- AGENTS.md generated
- Audit protocol optional module recommended

### Step 4: Route

Based on assessment, follow exactly ONE path:

#### Path A: Kit Not Installed + Empty/New Repo -> Full Init
No `claude-ops.json`, no `.claude/` directory, repo is empty or near-empty.

> "This looks like a fresh project. I'll walk you through a full claude-ops-kit setup."

**Read and follow:** `procedures/init.md`

#### Path B: Kit Not Installed + Existing Repo -> Adopt/Merge
No `claude-ops.json`, but `.claude/`, `CLAUDE.md`, rules, skills, or agents already exist.

> "You have existing Claude Code setup. I'll assess what you have and intelligently merge the kit alongside it."

**Read and follow:** `procedures/adopt.md`

#### Path C: Kit Installed + Version Mismatch -> Offer Choice
`claude-ops.json` exists and its `version` field differs from `KIT_VERSION`.

Read `KIT_ROOT/CHANGELOG.md` and extract entries newer than the installed version. Present a brief summary:

> "You're on kit v{installed}. The latest is v{kit}. Here's what's new:
> - {bullet summary of changes}
>
> Would you like to:
> 1. **Upgrade** — Walk through the changes and selectively adopt them
> 2. **Contribute** — Share your patterns, skills, or learnings back to the kit"

- If **Upgrade**: Read and follow `procedures/upgrade.md`
- If **Contribute**: Read and follow `procedures/contribute.md`

#### Path D: Kit Installed + Version Match -> Offer Contribute or Evaluate
`claude-ops.json` exists and version matches `KIT_VERSION`.

> "You're up to date on kit v{version}.
>
> Would you like to:
> 1. **Evaluate** — Score your project's ops kit comprehensiveness
> 2. **Contribute** — Share your patterns, skills, or learnings back to the kit
> 3. **Re-assess** — Re-run the setup to add modules you skipped initially"

- If **Evaluate**: Read and follow `procedures/evaluate.md`
- If **Contribute**: Read and follow `procedures/contribute.md`
- If **Re-assess**: Read and follow `procedures/adopt.md` (treats current state as existing setup)

### Step 5: Update Registry

After ANY path completes, update the kit's `registry/projects.json` with the project's current state. Read and follow `procedures/assess.md` for the evaluation criteria, then update or add the project entry with:

- `name`, `summary`, `repo`, `stack`
- `kitVersion` (the version just installed/upgraded to)
- `installedModules` (baseline + selected optional modules)
- `evalScore` and `evalBreakdown` (from evaluation)
- `lastAssessed` (today's date)

## Rules

- Never overwrite user files without showing what would change and getting confirmation
- When merging, always prefer the user's customizations — the kit provides defaults, the user provides intent
- Always explain WHY a module or rule is recommended, not just WHAT it does
- If the user's existing setup has something better than the kit's version, note it for contribution
- Present choices conversationally, not as numbered menus with single-letter codes
