#!/usr/bin/env bash
set -euo pipefail

# Configuration
INSTALL_DIR="$HOME/.ytbdht42"
SCRIPT_NAME="ytbdht42.sh"
ALIAS_CMD="alias ytbdht42=\"$INSTALL_DIR/$SCRIPT_NAME\""
PROFILE_FILES=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile")

# ANSI Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Progress tracking
TMPFILE=$(mktemp /tmp/ytbdht42_progress.XXXXXX)
start_time=$(date +%s)
PROGRESS_PID=""

# Cleanup function
cleanup() {
    rm -f "$TMPFILE"
    if [[ -n "$PROGRESS_PID" ]] && ps -p "$PROGRESS_PID" >/dev/null 2>&1; then
        kill "$PROGRESS_PID" 2>/dev/null || true
    fi
    echo -ne "\033[?25h"  # Show cursor
}
trap cleanup EXIT

# Smooth progress updater
smooth_update_progress() {
    local target=$1
    local message=$2
    local current=$(awk -F'|' '{print $1}' "$TMPFILE" 2>/dev/null || echo 0)
    while [[ $current -lt $target ]]; do
        current=$((current + 1))
        echo "${current}|${message}" > "$TMPFILE"
        sleep 0.05
    done
}

# Progress display with preservation
progress_display() {
    echo -ne "\033[?25l"  # Hide cursor
    
    local spinner=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local spinner_index=0
    local last_progress=0
    local last_message=""
    local width=50
    
    while true; do
        if [[ ! -f "$TMPFILE" ]]; then
            break
        fi
        
        IFS="|" read -r progress message < "$TMPFILE" || continue
        progress=${progress:-0}
        message=${message:-Working...}

        if [[ "$progress" != "$last_progress" || "$message" != "$last_message" ]]; then
            local filled=$((progress * width / 100))
            local elapsed_time=$(( $(date +%s) - start_time ))
            local time_str=$(printf "%02d:%02d" $((elapsed_time/60)) $((elapsed_time%60)))
            
            local bar=$(printf "[${RED}%-${width}s${NC}]" "$(printf "%${filled}s" | tr ' ' '#')")
            
            local line=$(printf "\r%s %-25s %s %3d%% ${BLUE}%8s${NC}" \
                "${spinner[spinner_index]}" \
                "$message" \
                "$bar" \
                "$progress" \
                "$time_str")
            
            echo -ne "$line"
            
            spinner_index=$(( (spinner_index + 1) % ${#spinner[@]} ))
            last_progress=$progress
            last_message="$message"
        fi
        
        sleep 0.08
    done
}

main_uninstallation() {
    echo "0|Initializing..." > "$TMPFILE"
    progress_display &
    PROGRESS_PID=$!

    # Remove installation directory
    smooth_update_progress 10 "Checking installation"
    if [[ -d "$INSTALL_DIR" ]]; then
        smooth_update_progress 20 "Removing directory"
        rm -rf "$INSTALL_DIR"
        smooth_update_progress 30 "Directory removed"
    else
        smooth_update_progress 30 "No installation found"
    fi

    # Clean up shell profiles
    smooth_update_progress 40 "Checking shell profiles"
    for profile in "${PROFILE_FILES[@]}"; do
        if [[ -f "$profile" ]]; then
            if grep -Fxq "$ALIAS_CMD" "$profile"; then
                smooth_update_progress 50 "Removing from $(basename "$profile")"
                sed -i.bak "\|^${ALIAS_CMD}$|d" "$profile"
                smooth_update_progress 60 "Profile cleaned"
            else
                smooth_update_progress 55 "No alias in $(basename "$profile")"
            fi
        fi
    done

    # Finalize
    smooth_update_progress 80 "Finalizing"
    sleep 1
    smooth_update_progress 100 "Uninstallation complete"
    sleep 0.5

    kill $PROGRESS_PID 2>/dev/null || true
    PROGRESS_PID=""
    echo ""
}

echo -e "${YELLOW}Starting ytbdht42 uninstallation...${NC}"
main_uninstallation
