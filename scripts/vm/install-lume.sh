#!/usr/bin/env bash
#
# Idempotent Lume install on the host Mac.
# Runs the official install script and prints PATH instructions if ~/.local/bin is not in PATH.
# Requires: Apple Silicon Mac, macOS 13+.
#
set -euo pipefail

LUME_INSTALL_URL="https://raw.githubusercontent.com/trycua/cua/main/libs/lume/scripts/install.sh"
LOCAL_BIN="$HOME/.local/bin"

if command -v lume &>/dev/null; then
  echo "Lume is already installed: $(lume --version)"
  exit 0
fi

echo "Installing Lume..."
/bin/bash -c "$(curl -fsSL "$LUME_INSTALL_URL")"

if ! command -v lume &>/dev/null; then
  if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
    echo ""
    echo "Lume was installed but is not on your PATH. Add it with:"
    echo "  echo 'export PATH=\"\$PATH:$LOCAL_BIN\"' >> ~/.zshrc && source ~/.zshrc"
    echo ""
    echo "Or restart your terminal after adding the line above."
    exit 1
  fi
fi

echo "Lume installed: $(lume --version)"
