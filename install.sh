#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="$HOME/.ytbdht42"
REPO_URL="https://github.com/ababdelo/YTBDHT42.git"
SCRIPT_NAME="ytbdht42.sh"
ALIAS_CMD="alias ytbdht42=\"$INSTALL_DIR/$SCRIPT_NAME\""
PROFILE_FILES=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile")

# Check for dependencies
for cmd in git curl bash; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "• Error: Required command '$cmd' not found. Please install it first." >&2
    exit 1
  fi
done

# Skip install if already present
if [[ -d "$INSTALL_DIR" ]]; then
  echo "• ytbdht42 is already installed in $INSTALL_DIR"
else
  echo "• Installing ytbdht42 to $INSTALL_DIR..."
  git clone --depth=1 "$REPO_URL" "$INSTALL_DIR"
  chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
  echo "• Clone complete."
fi

# Ensure alias is in your shell profile(s)
echo
echo "• Configuring your shell profiles..."
for profile in "${PROFILE_FILES[@]}"; do
  if [[ -f "$profile" ]]; then
    if grep -Fxq "$ALIAS_CMD" "$profile"; then
      echo "  • Alias already present in $(basename "$profile")"
    else
      echo "$ALIAS_CMD" >> "$profile"
      echo "  • Added to $(basename "$profile")"
    fi
  fi
done

# Reload profiles by launching a new login shell
echo
echo "•  Restarting your shell so changes take effect…"
exec "$SHELL" -l
