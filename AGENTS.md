# AGENTS.md — claude-ops-kit

> Project-agnostic bootstrap framework for Claude Code workflows. Provides templates, registry, playbook, and CLI tools for initializing and managing AI coding agent workflows across multiple projects.

## Project Overview

- **Stack:** bash, markdown, json (meta-tool — no application code)
- **Source:** `templates/`, `scripts/`, `registry/`, `playbook/`
- **Primary extension:** `.md`, `.sh`, `.json`

## Coding Conventions

- Template files use `.tmpl` extension with `{{VARIABLE}}` substitution
- Non-template files are copied verbatim
- Shell scripts use `set -euo pipefail`
- JSON files must be valid (test with `jq`)
- Rule files should be concise — prohibition-framed where possible

## Behavioral Rules

### Investigation-First
When modifying existing templates or scripts, read the file first. Trace how it's used by init/adopt/upgrade before changing it.

### Anti-Spiral
Never apply fix-on-fix. If a template change breaks something, re-investigate the template system rather than patching around it.

### Git Safety
Never silently resolve merge conflicts. Never force-push without approval. Prefer new commits over amends.

### Confidence Flagging
When touching shell script behavior across platforms (Windows/macOS/Linux), mark confidence: VERIFIED, ASSUMED, or UNVERIFIED.

## File Organization

- `CLAUDE.md` — Detailed instructions for working in this repo
- `templates/` — Baseline, optional, and stack-preset templates
- `registry/` — Cross-project inventory (JSON)
- `playbook/` — Narrative pattern docs and learnings
- `scripts/` — CLI automation and kit management
- `.claude/rules/` — Behavioral rules (self-hosted from templates)
- `.claude/skills/` — Workflow skills (handoff, claude-ops-kit onboarding)
