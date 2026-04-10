# Procedure: Contribute Back to Kit

Catalogs the user's custom patterns, skills, agents, rules, and learnings for potential inclusion in claude-ops-kit. This is the "share back" flow — the user has built something good and wants to feed it upstream.

## Prerequisites
- `KIT_ROOT` is resolved
- The user's project has custom Claude Code artifacts worth reviewing

## Phase 1: Catalog User Artifacts

Scan the user's project for everything that goes beyond the kit's defaults. For each artifact, read its content to understand quality and applicability.

### What to Scan

**Custom rules** (`.claude/rules/` files not in kit baseline or stack presets):
- Read each one
- Note: what problem does it solve? Is it project-specific or generalizable?

**Custom skills** (`.claude/skills/` directories not in kit):
- Read each SKILL.md
- Note: what workflow does it enable? Could other projects use it?

**Custom agents** (`.claude/agents/` directories not in kit):
- Read each CLAUDE.md
- Note: what role does it fill? Is it a variant of a kit agent or something new?

**CLAUDE.md customizations:**
- Compare the user's CLAUDE.md against the kit template
- Identify sections the user added or significantly enhanced
- Note: which additions would improve the baseline template?

**Memory and learnings:**
- Read `.claude/MEMORY.md` for accumulated patterns
- Check for any retrospectives or learnings docs
- Note: which insights are transferable to other projects?

**Workflow feedback:**
- Read `.claude/rules/workflow-feedback.md` if it has entries
- These are corrections and confirmations from the user — gold for improving defaults

**Known traps:**
- Read `.claude/rules/known-traps.md` if it has entries
- Platform/framework gotchas that other projects would benefit from

## Phase 2: Triage

Categorize each finding into one of four buckets:

### Baseline Worthy
Should be included in every project. Criteria:
- Solves a problem that affects most/all projects
- Not stack-specific
- Battle-tested (user has been using it successfully)
- Concise and clear

### Optional Module Worthy
Valuable but situational. Criteria:
- Solves a real problem but only for certain project types
- Could become a new optional module or enhance an existing one
- Has enough substance to stand on its own

### Snippet Merge
Not a standalone addition, but contains insights that should be woven into existing kit files. Criteria:
- A better phrasing of an existing rule
- An additional example or edge case for an existing pattern
- A refinement to a template section

### Abstain
Interesting but not a fit for the kit. Criteria:
- Too project-specific to generalize
- Solves a problem unique to one codebase or framework
- Duplicates something the kit already handles well

## Phase 3: Present Findings

Show the user what you've cataloged, organized by bucket:

> **Contribution Review: {project-name}**
>
> **Baseline worthy (would improve every project):**
> - `task-delay-safety.md` — prevents async timing bugs. This pattern applies to any project with async operations, not just Luau. I'd generalize it as an "async-safety" rule.
> - Your CLAUDE.md "Verify before implementing" section is more thorough than the kit's. The kit should adopt your phrasing.
>
> **Optional module worthy:**
> - `catalog-api-safety.md` — great rule but specific to projects with catalog/inventory APIs. Could become part of a "commerce-patterns" optional module.
> - Your `design-system` skill is well-structured. Other UI projects would benefit.
>
> **Snippet merges (improvements to existing kit files):**
> - Your git-safety rule adds stash protection. The kit's version should include this.
> - Your workflow-feedback has 3 entries about merge conflict handling — these should inform the kit's `git-safety.md`.
>
> **Abstaining:**
> - `argon-safety.md` — Roblox-specific, already covered by the luau stack preset
> - `canvas-group-clipping.md` — too specific to your UI implementation
>
> Does this look right? Want to adjust any categorizations?

## Phase 4: Package for Kit

After the user confirms, prepare the contributions. Do NOT directly modify the kit repo from the user's project. Instead:

### Option A: Working from the Kit Repo
If the user is running this from the kit repo (or switches to it), apply changes directly:
- Copy baseline-worthy artifacts to `templates/baseline/`
- Copy optional-worthy artifacts to `templates/optional/`
- Apply snippet merges to existing files
- Update `CHANGELOG.md` with contribution notes

### Option B: Working from the User's Project
Create a contribution manifest that can be applied later:

```json
{
  "contributor": "{project-name}",
  "date": "{today}",
  "contributions": [
    {
      "type": "baseline",
      "artifact": "async-safety.md",
      "source": ".claude/rules/task-delay-safety.md",
      "notes": "Generalized from Luau task.delay to universal async timing patterns",
      "action": "new-rule"
    },
    {
      "type": "snippet",
      "target": "templates/baseline/claude/rules/git-safety.md",
      "source": ".claude/rules/git-safety.md",
      "notes": "Add stash protection section from user's version",
      "action": "merge"
    }
  ]
}
```

Save this as `contribution-{project-name}-{date}.json` in `KIT_ROOT/registry/contributions/` (create the directory if needed).

> "I've packaged your contributions. Next time you open a session in the kit repo, these will be ready for review and integration."

## Phase 5: Update Registry

Update `registry/projects.json` to note the contribution:
- Add `lastContribution` date to the project entry
- Update `customRules`, `skills`, etc. to reflect current state
