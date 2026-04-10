# Procedure: Adopt/Merge Kit into Existing Project

Integrates claude-ops-kit into a project that already has some Claude Code setup. The key principle: **the user's existing work is always respected** — the kit fills gaps, never overwrites.

## Prerequisites
- `KIT_ROOT` is resolved
- `KIT_VERSION` is known
- The project has existing `.claude/` files, `CLAUDE.md`, or other Claude Code artifacts but no `claude-ops.json`

## Phase 1: Deep Assessment

Scan the project thoroughly. Don't just check file existence — read the content to understand what the user has built.

### Scan Checklist

**Root documents:**
- [ ] `CLAUDE.md` — Read it. Note which sections exist, what's custom, what's generic
- [ ] `PROJECT_STATE.md` — Does it exist? Is it actively maintained?
- [ ] `REFERENCE_MAP.md` — Present? Up to date?
- [ ] `DOMAINS.md` — Present?
- [ ] `backlog.json` — Present? How many tasks?

**Claude Code internals:**
- [ ] `.claude/rules/` — List all rules. For each, note if it's a kit baseline rule or custom
- [ ] `.claude/skills/` — List all skills. Read each SKILL.md to understand what they do
- [ ] `.claude/agents/` — List all agents. Read each CLAUDE.md
- [ ] `.claude/MEMORY.md` — Present? Has content?
- [ ] `.claude/setup/` — Present? Which platforms?
- [ ] `.claude/settings.json` — Present? What hooks are configured?

**Infrastructure:**
- [ ] `.githooks/` — Any hooks present?
- [ ] `scripts/` — Any Claude-related scripts?
- [ ] `.gitignore` — Does it cover `.claude/worktrees/`, `.env`, etc.?

### Stack Detection

Same auto-detection as init (package.json, tsconfig, etc.). Confirm with the user.

### Collect Missing Metadata

Through conversation, gather any values not derivable from the project:
- Project description (one sentence)
- Task prefix (if they use task IDs)
- Lint/format/test commands (detect from package.json scripts, Makefile, etc.)

## Phase 2: Gap Analysis

Compare what exists against what the kit provides. Organize into three buckets:

### Already Covered
Things the user has that match or exceed kit equivalents. Don't touch these.

> "You already have: CLAUDE.md with detailed architecture, 5 custom rules, a handoff skill, and pre-commit hooks. These are solid — I won't change them."

### Gaps to Fill
Kit components the user is missing. These are safe to add.

> "I'd recommend adding:
> - **anti-spiral rule** — prevents fix-stacking spirals (you don't have anything like this)
> - **confidence-flagging rule** — marks API assumptions as verified/assumed/unverified
> - **sync-memory.sh** — backs up your memory to git-tracked storage
> - **check-version.sh** — notifies you when the kit has updates"

### Merge Candidates
Cases where both the user and the kit have content for the same purpose, but they differ. These require careful handling.

> "A few things need your input:
> - Your **CLAUDE.md** has a custom 'Session Start' section. The kit's version adds version checking and memory sync steps. Want me to weave those into yours?
> - You have a **git-safety rule** that's stricter than the kit's default (yours forbids force-push entirely). I'd keep yours — it's better."

## Phase 3: Merge Strategy

For each merge candidate, follow these principles:

### CLAUDE.md Merging
- **Never replace** the user's CLAUDE.md
- Read the kit template and the user's version side by side
- Identify sections in the kit template that have no equivalent in the user's file
- For missing sections: propose the addition with the exact content, showing where it would go
- For overlapping sections: compare and recommend whichever is more thorough (often the user's)
- Present the proposed changes as a diff-like summary before applying

### Rule Merging
- Kit baseline rules with no user equivalent: add them
- Kit rules where user has a same-named file: keep the user's version (it may be customized)
- User custom rules not in the kit: leave untouched, note them as potential contributions

### Skill Merging
- Kit skills with no user equivalent: offer to add
- Same-named skills: keep the user's version, note if kit version has useful additions
- User custom skills: leave untouched, note as potential contributions

### Agent Merging
- Same logic as skills

### Settings Merging
- If `.claude/settings.json` exists, merge hooks carefully — don't remove existing hooks
- Add the SessionStart version check hook if not already present

## Phase 4: Execute with Confirmation

Present the full plan before making any changes:

> "Here's my plan:
>
> **Adding (new files):**
> - `.claude/rules/anti-spiral.md`
> - `.claude/rules/confidence-flagging.md`
> - `scripts/sync-memory.sh`
> - `scripts/check-version.sh`
>
> **Merging (adding to existing):**
> - `CLAUDE.md` — adding Session Infrastructure section after your existing Session Start
> - `.claude/settings.json` — adding SessionStart hook alongside your existing hooks
>
> **Keeping as-is (yours is better or equivalent):**
> - `.claude/rules/git-safety.md` (your version is stricter)
> - `.claude/skills/handoff/SKILL.md` (your version is customized)
>
> Want me to proceed, or adjust anything?"

Only execute after the user confirms.

## Phase 5: Generate Manifest

Create `claude-ops.json` that accurately reflects the merged state — including both kit-provided and user-original components in the features list.

Set `"adoptedFrom": "existing"` to mark this as an adoption rather than a fresh init.

## Phase 6: Summary

Focus on what value was added, not what files were created:

> "Done. Your project now has:
> - **3 new rules** covering anti-spiral, confidence flagging, and phase gates
> - **Memory sync** so your session context survives across machines
> - **Version checking** so you'll know when the kit improves
> - All your existing customizations preserved
>
> Your 5 custom rules and handoff skill are great candidates to contribute back to the kit. Want to do that now, or save it for later?"
