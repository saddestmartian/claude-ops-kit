#!/bin/bash
# install.sh — Install claude-ops CLI to PATH
set -euo pipefail

KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLI="$KIT_ROOT/bin/claude-ops"

chmod +x "$CLI"

# Determine install location
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"
    # Copy bash script for Git Bash usage
    cp "$CLI" "$INSTALL_DIR/claude-ops"
    sed -i "s|^KIT_ROOT=.*|KIT_ROOT=\"$KIT_ROOT\"|" "$INSTALL_DIR/claude-ops"

    # Create .cmd shim that calls Git Bash directly (no PowerShell middle layer)
    # This preserves stdin for interactive prompts (read -rp in adopt/init)
    GITBASH_EXE=""
    for p in "C:\\Program Files\\Git\\bin\\bash.exe" "C:\\Program Files (x86)\\Git\\bin\\bash.exe"; do
        if [ -f "$(cygpath -u "$p")" ]; then
            GITBASH_EXE="$p"
            break
        fi
    done
    if [ -z "$GITBASH_EXE" ]; then
        GITBASH_EXE="bash.exe"
    fi

    UNIX_KIT_ROOT="$(echo "$KIT_ROOT" | sed 's|^/\([a-zA-Z]\)/|/\1/|')"
    cat > "$INSTALL_DIR/claude-ops.cmd" <<CMDEOF
@echo off
"$GITBASH_EXE" --login -c "$UNIX_KIT_ROOT/bin/claude-ops %*"
CMDEOF
    # Remove any stale .ps1 from install dir (prevents PS auto-discovery)
    rm -f "$INSTALL_DIR/claude-ops.ps1"

    echo "Installed claude-ops to $INSTALL_DIR/"
    echo "  claude-ops      (Git Bash)"
    echo "  claude-ops.cmd  (PowerShell/CMD)"
    echo ""
    echo "Ensure $INSTALL_DIR is in your PATH:"
    echo "  Add to ~/.bashrc:  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo "  Add to PowerShell profile:  \$env:PATH = \"\$env:USERPROFILE\\.local\\bin;\$env:PATH\""
else
    INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"
    ln -sf "$CLI" "$INSTALL_DIR/claude-ops"
    echo "Installed claude-ops to $INSTALL_DIR/claude-ops (symlink)"
    echo ""
    echo "Ensure $INSTALL_DIR is in your PATH:"
    echo "  Add to ~/.zshrc:  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

# Verify
if command -v claude-ops &>/dev/null; then
    echo ""
    claude-ops version
    echo "Ready to use! Run 'claude-ops init' in any project."
else
    echo ""
    echo "⚠ claude-ops is not in PATH yet."
    echo "Add $INSTALL_DIR to your PATH, then restart your shell."
fi
