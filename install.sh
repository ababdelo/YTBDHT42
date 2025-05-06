#!/usr/bin/env bash
set -euo pipefail

# Configuration
INSTALL_DIR="$HOME/.ytbdht42"
REPO_URL="https://github.com/ababdelo/YTBDHT42.git"
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
    local width=50  # Fixed width between brackets
    
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
            
            # Create fixed-width bar with filled portion
            local bar=$(printf "[${GREEN}%-${width}s${NC}]" "$(printf "%${filled}s" | tr ' ' '#')")
            
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

# Dependency check
check_dependencies() {
    for cmd in git curl bash; do
        if ! command -v "$cmd" &>/dev/null; then
            echo -e "${RED}Error: Required command '$cmd' not found. Please install it first.${NC}" >&2
            exit 1
        fi
    done
}

remove_existing() {
    smooth_update_progress 10 "Removing existing install"
    rm -rf "$INSTALL_DIR"
    smooth_update_progress 20 "Cleanup complete"
}

main_installation() {
    echo "0|Initializing..." > "$TMPFILE"
    progress_display &
    PROGRESS_PID=$!

    if [[ "$REINSTALL" == "true" ]]; then
        echo -e "${YELLOW}Reinstalling YTBDHT42${NC}"
        remove_existing
    else
        smooth_update_progress 20 "Preparing installation"
    fi

    smooth_update_progress 25 "Checking dependencies"
    check_dependencies

    smooth_update_progress 30 "Cloning repository"
    git clone --depth=1 "$REPO_URL" "$INSTALL_DIR" >/dev/null 2>&1 &
    CLONE_PID=$!

    while kill -0 $CLONE_PID 2>/dev/null; do
        current=$(awk -F'|' '{print $1}' "$TMPFILE")
        if [[ $current -lt 50 ]]; then
            smooth_update_progress $((current + 1)) "Cloning repository"
        fi
        sleep 0.2
    done
    wait $CLONE_PID || {
        echo "0|${RED}Clone failed!${NC}" > "$TMPFILE"
        echo -e "\n${RED}Installation aborted: Failed to clone repository!${NC}"
        exit 1
    }

    smooth_update_progress 60 "Setting permissions"
    chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

    smooth_update_progress 75 "Configuring shell"
    for profile in "${PROFILE_FILES[@]}"; do
        if [[ -f "$profile" ]] && ! grep -Fxq "$ALIAS_CMD" "$profile"; then
            echo "$ALIAS_CMD" >> "$profile"
        fi
    done

    smooth_update_progress 90 "Finalizing installation"
    sleep 1

    smooth_update_progress 100 "Installation completed"
    sleep 0.5

    kill $PROGRESS_PID 2>/dev/null || true
    PROGRESS_PID=""
    echo ""  # Preserve final progress bar with newline
}

# Initialize reinstall flag
REINSTALL="false"

if [[ -d "$INSTALL_DIR" ]]; then
    echo -e "${YELLOW}YTBDHT42 is already installed.${NC}"
    read -p "Do you want to (U)pdate, (R)einstall, or (S)kip? [U/r/s]: " choice
    case "$choice" in
        [Rr]* )
            REINSTALL="true"
            main_installation
            ;;
        [Uu]* )
            echo "0|Updating YTBDHT42" > "$TMPFILE"
            progress_display &
            PROGRESS_PID=$!

            cd "$INSTALL_DIR" && git pull origin main >/dev/null 2>&1
            for i in {1..100}; do
                echo "$i|Updating YTBDHT42" > "$TMPFILE"
                sleep 0.02
            done

            kill $PROGRESS_PID 2>/dev/null || true
            PROGRESS_PID=""
            echo -e "\n${GREEN}Update successful!${NC}"  # Newline before message
            exit 0
            ;;
        [Ss]* | "" )
            echo -e "${YELLOW}Skipping installation.${NC}"
            exit 0
            ;;
        * )
            echo -e "${RED}Invalid option. Aborting.${NC}"
            exit 1
            ;;
    esac
else
    main_installation
fi

end_time=$(date +%s)
time_taken=$((end_time - start_time))