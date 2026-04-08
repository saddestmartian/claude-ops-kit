# Sub-Agent Orchestration

## Worktree Agent Pattern
Sub-agents work in isolated git worktrees — separate copies of the repo that don't interfere with the main working directory.

### Workflow
1. **Commit new files FIRST** before launching worktree agents (they branch from HEAD)
2. Agent works in isolation, commits to a `worktree-agent-XXXX` branch
3. After agent completes, check branch: `git log --oneline worktree-agent-XXXX -3`
4. Cherry-pick: `git cherry-pick <hash>` or file-level: `git checkout worktree-branch -- path/to/file`
5. Stash local changes before cherry-pick if needed

### Gotchas
- `.claude/worktrees/` dirs can get staged as submodules — add to `.gitignore`
- After cherry-picking, verify you're in the main repo: `pwd` + `git branch --show-current`
- Agent work MUST be committed to a named branch before the worktree is cleaned up
- Worktrees are ephemeral — if the agent makes no changes, the worktree is auto-cleaned

### When to Use Sub-Agents
- **Parallel implementation** — multiple independent modules can be built simultaneously
- **Codebase exploration** — searching across large codebases without polluting main context
- **Audit waves** — each agent audits a different directory or concern
- **Testing** — run tests in isolation without affecting main working state

### When NOT to Use Sub-Agents
- Tasks that depend on each other's output
- Simple, sequential changes to 1-2 files
- When the task needs the full conversation context to make good decisions
