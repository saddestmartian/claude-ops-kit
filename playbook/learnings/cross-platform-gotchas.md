# Cross-Platform Gotchas

## Windows
- **MCP servers with `npx`:** Claude Code on Windows cannot spawn `npx` directly. Use `"command": "cmd", "args": ["/c", "npx", ...]` wrapper.
- **Line endings:** Always `git config core.autocrlf input` to avoid CRLF issues.
- **Shell scripts:** All `*.sh` files require Git Bash or WSL. Git for Windows includes Bash.
- **Path separators:** Use forward slashes in code. Windows Git Bash handles translation.
- **Symlinks:** Creating symlinks requires admin privileges on Windows. The installer copies files instead.

## macOS
- **Homebrew paths:** On Apple Silicon, Homebrew installs to `/opt/homebrew/bin/`. Older Macs use `/usr/local/bin/`.
- **Peekaboo MCP:** macOS-only screenshot tool. Not available on Windows.
- **Keychain:** `gh auth login` uses macOS keychain for token storage.

## Cloud (Claude Code mobile/desktop → cloud)
- **No local tools:** Linters, formatters, and project-specific CLI tools aren't installed.
- **No `gh` CLI:** Use `curl` with bearer token for GitHub API.
- **No `.env` file:** Tokens must be provided at session start.
- **Proxy:** External API calls may need `export https_proxy="$GLOBAL_AGENT_HTTP_PROXY"`.
- **Best for:** Planning, code review, writing code, documentation. Not for: local testing, tool execution.

## Universal
- **Memory paths differ by platform:** The `sync-memory.sh` script handles this by deriving the path from `git rev-parse --show-toplevel`.
- **Git hooks:** Use `#!/bin/sh` (not `#!/bin/bash`) for maximum portability.
- **jq dependency:** Required for backlog queries and verify-sync. Install via `brew install jq` or `winget install jqlang.jq`.
