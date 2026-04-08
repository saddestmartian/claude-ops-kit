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
    # On Windows, copy instead of symlink (symlinks need admin)
    cp "$CLI" "$INSTALL_DIR/claude-ops"
    # Bake the real kit root into the copy so VERSION resolution works
    sed -i "s|^KIT_ROOT=.*|KIT_ROOT=\"$KIT_ROOT\"|" "$INSTALL_DIR/claude-ops"
    echo "Installed claude-ops to $INSTALL_DIR/claude-ops"
    echo ""
    echo "Ensure $INSTALL_DIR is in your PATH:"
    echo "  Add to ~/.bashrc:  export PATH=\"\$HOME/.local/bin:\$PATH\""
else
    INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"
    ln -sf "$CLI" "$INSTALL_DIR/claude-ops"
    echo "Installed claude-ops to $INSTALL_DIR/claude-ops (symlink)"
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
