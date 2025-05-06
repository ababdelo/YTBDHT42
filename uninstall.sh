#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="$HOME/.ytbdht42"
SCRIPT_NAME="ytbdht42.sh"
ALIAS_CMD="alias ytbdht42=\"$INSTALL_DIR/$SCRIPT_NAME\""
PROFILE_FILES=( "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile" )

echo "• Uninstalling ytbdht42 …"

# 1) Remove install directory
if [[ -d "$INSTALL_DIR" ]]; then
  echo "  • Removing directory $INSTALL_DIR"
  rm -rf "$INSTALL_DIR"
else
  echo "  • No installation directory found at $INSTALL_DIR"
fi

# 2) Remove alias from profiles
echo
echo "• Cleaning up shell profiles:"
for profile in "${PROFILE_FILES[@]}"; do
  if [[ -f "$profile" ]]; then
    if grep -Fxq "$ALIAS_CMD" "$profile"; then
      # Delete the exact alias line (make a .bak backup)
      sed -i.bak "\|^${ALIAS_CMD}$|d" "$profile"
      echo "  • Removed alias from $(basename "$profile") (backup at ${profile}.bak)"
    else
      echo "  • No alias line in $(basename "$profile")"
    fi
  fi
done

# 3) Reload shell
echo
echo "• Restarting your shell to apply changes…"
exec "$SHELL" -l
echo "• Uninstallation complete."