# Procedure: Evaluate Project

Runs the full assessment rubric from `assess.md` and presents results with actionable recommendations.

## When to Use
- User selects "Evaluate" from the skill router
- After init/adopt/upgrade completes (automatically called by the router's Step 5)
- User wants to check their ops setup health

## Procedure

### Step 1: Run Assessment

Read and follow the scoring rubric in `procedures/assess.md`. Scan actual files, not just the manifest.

### Step 2: Present Results

Show the evaluation table with specific, honest notes for each category. Don't inflate scores — the user needs accurate feedback to improve.

> **Project Evaluation: ugc-world**
>
> | Category | Score | Notes |
> |----------|-------|-------|
> | Rules Coverage | 9/10 | 8 baseline + luau-conventions + 11 custom project rules |
> | Memory Hygiene | 7/10 | MEMORY.md maintained, sync exports present but 2 weeks stale |
> | Skill Usage | 8/10 | handoff, pr, design-system, video-toolkit — solid coverage |
> | Agent Templates | 8/10 | architecture-validator, design-advisor, design-auditor — all customized |
> | Git Discipline | 9/10 | Hooks active, good .gitignore, consistent branch workflow |
> | Documentation | 7/10 | CLAUDE.md detailed but Architecture section needs updating |
> | Session Infrastructure | 9/10 | All scripts present + SessionStart hook active |
>
> **Overall: 8.1/10 (well-equipped)**

### Step 3: Recommendations

Provide 2-4 specific, actionable improvements ordered by impact:

> **To reach gold-standard:**
> 1. **Update CLAUDE.md architecture section** — it references the old module layout from before the refactor
> 2. **Run `scripts/sync-memory.sh export`** — your last export was April 1st, you've had 5 sessions since
> 3. **Consider a code-reviewer agent** — you're the only contributor, automated review catches what self-review misses

Don't suggest things that don't fit the project. A solo Roblox game doesn't need a retrospective template.

### Step 4: Update Registry

Update `registry/projects.json` with the evaluation results. Follow the format in `assess.md`.

If the project already has a registry entry, update it in place. If not, add a new entry.

### Step 5: Offer Next Steps

> "Want me to help with any of these improvements now? Or would you like to contribute your custom rules back to the kit?"
