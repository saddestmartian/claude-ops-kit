# Procedure: Upgrade Kit Installation

Walks the user through updating their claude-ops-kit installation to a newer version. The key principle: **user customizations are sacred** — upgrades add and improve, never regress.

## Prerequisites
- `KIT_ROOT` is resolved
- `KIT_VERSION` is the latest version from the kit
- `claude-ops.json` exists with the currently installed version
- The installed version differs from `KIT_VERSION`

## Phase 1: Version Comparison

Read the installed version and the kit's CHANGELOG:

```bash
# Installed version
jq -r '.version' claude-ops.json

# Kit changelog
cat "$KIT_ROOT/CHANGELOG.md"
```

Extract all changelog entries between the installed version and `KIT_VERSION`. Present a clear summary:

> "You're on **v1.1.0**. The kit is now at **v1.2.0**. Here's what changed:
>
> ### New in v1.2.0
> - **claude-ops-kit skill** — conversational onboarding replaces shell script prompts
> - **Project evaluation scoring** — 7-category assessment of your ops setup
> - **Contribution workflow** — share your patterns back to the kit
> - Enriched project registry with eval scores and maturity labels
>
> No breaking changes in this release."

If there are breaking changes (major version bump), call them out explicitly and explain what they mean for the user.

## Phase 2: Delta Analysis

Compare the user's installed files against the current kit templates. Categorize every difference:

### New Kit Files
Files that exist in the kit but not in the user's project. These are safe to add.

### Updated Kit Files
Kit template files where the kit version has changed but the user also has the file. For each:

1. Check if the user's version matches their previously installed kit version (unmodified)
2. Check if the user has customized the file (differs from any kit version)

- **Unmodified by user**: Safe to update to latest kit version
- **User-customized**: Show the diff between the kit's old and new versions so the user can decide what to incorporate

### User-Only Files
Files the user has that aren't part of the kit at all. Leave these completely alone.

### Removed Kit Files
Files that existed in a previous kit version but were removed in the new version. Flag these:

> "The kit removed `{file}` in v{version}. Reason: {from changelog}. Your copy is still here — want to keep it or remove it?"

## Phase 3: Present Upgrade Plan

Show the complete plan organized by action:

> "Here's what the upgrade to v1.2.0 would do:
>
> **New files to add:**
> - `.claude/skills/claude-ops-kit/` — the new onboarding skill (6 files)
> - `.claude/rules/known-traps.md` — empty accumulator for platform gotchas
>
> **Files to update** (your copies are unmodified from v1.1.0):
> - `scripts/check-version.sh` — improved changelog diff display
> - `.claude/rules/code-discipline.md` — added function length guideline
>
> **Files with your customizations** (showing kit changes for your review):
> - `.claude/rules/git-safety.md` — kit added stash protection; your version already has this + more. **Recommend: keep yours.**
> - `CLAUDE.md` — kit added Model Routing section. **Recommend: merge this section into yours.**
>
> **No changes needed:**
> - Your 5 custom rules, 2 custom skills — untouched
>
> Proceed with this plan?"

## Phase 4: Execute Upgrade

After user confirmation, apply changes in order:

1. **Add new files** — copy/render from kit templates
2. **Update unmodified files** — replace with latest kit versions
3. **Merge customized files** — only the specific additions the user approved
4. **Update `claude-ops.json`** — bump version, update lastUpgrade date, add any new features

For CLAUDE.md merges, use the same careful approach as in `adopt.md`:
- Identify the specific new sections from the kit
- Propose exact insertion points in the user's file
- Show the content before inserting
- Get confirmation

## Phase 5: Verify

After applying changes:

1. Check that `.claude/settings.json` hooks are intact (not clobbered)
2. Verify `git config core.hooksPath` is still `.githooks`
3. Run a quick lint check if the user has a lint command configured
4. Confirm `claude-ops.json` version matches `KIT_VERSION`

## Phase 6: Summary

> "Upgrade complete: **v{old} -> v{new}**
>
> - Added {n} new files
> - Updated {n} kit files
> - Merged {n} additions into your customized files
> - Your {n} custom files untouched
>
> Run `/claude-ops-kit` again anytime to evaluate your setup or contribute patterns back."
