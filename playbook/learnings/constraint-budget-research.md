# Constraint Budget and Behavioral Control Research

Findings from April 2026 research survey across 30+ academic papers, production deployments, and open-source community patterns. These findings directly informed the kit's rule design and onboarding architecture.

## Core Findings

### 1. Constraints impose a cognitive tax (SustainScore, arXiv 2601.22047)
Even self-evident constraints — derived from a model's own successful output — cause 15-35% performance drops in 30B-70B parameter models. The sharpest degradation happens within the first 5 constraints, then plateaus. Every always-on rule costs something.

**Kit implication:** Baseline rules compressed from ~28 sub-constraints to ~16. Prohibition framing used everywhere possible.

### 2. Prohibitions degrade slower than instructions (LocalLLaMA research)
"NEVER do X" constraints function at the logit level and don't require sustained attention. "ALWAYS do Y" instructions compete for attention as context grows. Over long conversations, prohibitions remain effective while instructions silently fade.

**Kit implication:** All baseline rules reframed as prohibitions where semantically equivalent.

### 3. Instruction hierarchy is unreliable (arXiv 2502.15851)
System/user prompt separation fails to establish consistent priority. Primary Obedience Rates drop to 9.6%-45.8% when constraints conflict. Societal hierarchy framings (expertise, consensus) influence behavior more than positional system/user roles.

**Kit implication:** Rules designed to be conflict-free rather than relying on priority. No overlapping constraints between rules.

### 4. Context rot is real and predictable (Chroma Research)
Performance degrades as input length grows across all 18 tested models. "Lost-in-the-middle" effect means rules set at session start get buried after 30+ messages. Shuffled context paradoxically outperforms structured context at scale.

**Kit implication:** Phase gates should re-inject relevant rule subsets, not rely on session-start rules persisting.

### 5. Right complexity depends on context (Cline vs Roo Code, Qodo)
Enterprise teams prefer safety-first approaches (explicit approval gates). Solo developers prefer speed-first approaches (autonomous execution). Vanilla Claude Code outperforms complex workflow systems for simple tasks.

**Kit implication:** Solo/Team/Enterprise profiles scale complexity to match. Don't impose max structure on everyone.

### 6. AGENTS.md is the cross-tool standard (60,000+ repos, Linux Foundation)
AGENTS.md presence reduces median agent runtime by 28.64% and output tokens by 16.58%. Adopted by Codex, Copilot, Cursor, Windsurf, Amp, Jules, Devin.

**Kit implication:** Generate AGENTS.md alongside CLAUDE.md for cross-tool compatibility.

## Key References

- **SustainScore:** arXiv 2601.22047 — constraint performance tax
- **Instruction hierarchy failure:** arXiv 2502.15851 — system/user priority unreliable
- **AGENTS.md impact:** arXiv 2601.20404 (Lulla et al.) — 28.64% runtime reduction
- **Context rot:** trychroma.com/research/context-rot — 18-model degradation study
- **Instruction gap:** arXiv 2601.03269 — enterprise RAG instruction violation rates
- **Community best practices:** shanraisshan/claude-code-best-practice (35K stars)
- **Dotfiles for AI:** PatrickJS/awesome-cursorrules (39K stars)
- **DX AI Measurement:** getdx.com — utilization x impact x cost framework
- **Self-improving agents:** Datagrid — memory evolution, validation gates, feedback routing

## Design Principles Derived

1. **Constraint budget is finite.** Every rule costs cognitive overhead. Always-on rules should be the ceiling, not the floor.
2. **Prohibition-first framing.** "NEVER" degrades slower than "ALWAYS" in long context.
3. **Conflict-free by design.** Don't rely on hierarchy to resolve rule conflicts — eliminate conflicts.
4. **Progressive disclosure.** Load rules contextually via skills, not globally. Use `context: fork` for isolated execution.
5. **Sanctioned overrides.** Rules without escape hatches get silently circumvented — controlled deviation beats silent deviation.
6. **Harness over guidance.** Anything that MUST be enforced belongs in `settings.json` hooks, not CLAUDE.md. The model can't override hooks.
7. **Re-inject at gates.** Don't trust session-start rules to persist. Phase gates should re-state relevant constraints.
8. **Profile-matched complexity.** Solo/Team/Enterprise — match the framework's weight to the project's needs.
