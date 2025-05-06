#!/usr/bin/env bash

# Define colors
WHITE="\033[1;37m"
GREY="\033[1;90m"
BLACK="\033[1;30m"
BROWN="\033[1;38;5;88m"
ORANGE="\033[1;38;5;208m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
GREEN="\033[1;32m"
MAGENTA="\033[1;35m"
PINK="\033[1;38;5;205m"
RESET="\033[0m"

set -euo pipefail

# Initialize variables
source_url=""
dest_dir="$(pwd)"
ext=""
resolution=480
list_only=false
force_pl=false
download_subs=false
subs_lang="en"
template="%(title)s.%(ext)s"
count=""
version="v1.0"

# Show help
show_help() {
  echo
  echo -e "${GREEN}ytbdht42 ${WHITE}YOUTUBE DOWNLOADER HELPER TOOL${RESET}"
  echo -e "${BLUE}Description: ${WHITE}This tool simplifies using yt-dlp to download YouTube medias."
  echo -e "${BLUE}Author: ${WHITE}ababdelo${RESET}"
  echo -e "${BLUE}Version:${WHITE} ${version}${RESET}"
  echo -e "${BLUE}Usage${RESET}: ${WHITE}ytbdht42 [options] URL${RESET}"
  echo
  echo -e "Options:"
  echo -e "  ${GREEN}-s, --source${RESET}        ${WHITE}YouTube URL (video/channel/playlist)${RESET}"
  echo -e "  ${CYAN}-d, --destination${RESET}   ${WHITE}Output directory (default: current dir)${RESET}"
  echo -e "  ${BLUE}-f, --format${RESET}        ${WHITE}Format: mp4/mkv/webm (video) or mp3/wav/m4a (audio)${RESET}"
  echo -e "  ${YELLOW}-r, --resolution${RESET}    ${WHITE}Video resolution (144,240,360,480,720,1080; default: 480)${RESET}"
  echo -e "  ${ORANGE}-l, --list${RESET}          ${WHITE}List titles of a YouTube channel or playlist${RESET}"
  echo -e "  ${BROWN}-p, --playlist${RESET}      ${WHITE}Force playlist download${RESET}"
  echo -e "  ${RED}-e, --subtitles${RESET}     ${WHITE}Download subtitles (optional LANG, default: en)${RESET}"
  echo -e "  ${PINK}-n, --name${RESET}          ${WHITE}Custom media output filename${RESET}"
  echo -e "  ${MAGENTA}-c, --count${RESET}         ${WHITE}Download first N playlist items${RESET}"
  echo -e "  ${GREEN}-v, --version${RESET}       ${WHITE}Show version${RESET}"
  echo -e "  ${BLUE}-h, --help${RESET}          ${WHITE}Show this help message${RESET}"
  echo
  exit 0
}

# If no args at all, show help
if [[ $# -eq 0 ]]; then
  show_help
fi

# Check dependencies
if ! command -v yt-dlp &>/dev/null; then
  echo -e "${RED}Error:${RESET} yt-dlp not found. Please install it first." >&2
  exit 1
fi

# Help function and version are handled in parsing below

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--source)
      source_url="$2"; shift 2;;
    -d|--destination)
      dest_dir="$2"; shift 2;;
    -f|--format)
      ext="${2,,}"; shift 2;;
    -r|--resolution)
      resolution="$2"; shift 2;;
    -l|--list)
      list_only=true; shift;;
    -p|--playlist)
      force_pl=true; shift;;
    -e|--subtitles)
      download_subs=true
      if [[ $# -ge 2 && ! "$2" =~ ^- ]]; then
        subs_lang="$2"; shift 2
      else
        shift
      fi;;
    -n|--name)
      template="$2"; shift 2;;
    -c|--count)
      count="$2"; shift 2;;
    -v|--version)
      echo -e "ytbdht42 version ${version}"; exit 0;;
    -h|--help)
      show_help;;
    *)
      if [[ -z "$source_url" ]]; then
        source_url="$1"
      else
        echo -e "${RED}Error:${RESET} Unknown option: $1" >&2
        exit 1
      fi
      shift;;
  esac
done

# Validate URL (after parsing)
if [[ -z "$source_url" ]]; then
  show_help
fi

mkdir -p "$dest_dir"

# List mode
if $list_only; then
  yt-dlp --flat-playlist --get-title "$source_url" |
    awk '{ printf "%2d. %s\n", NR, $0 }'
  exit 0
fi

# Determine mode and extension
audio_exts=(mp3 wav m4a)
video_exts=(mp4 mkv webm)
if [[ -n "${ext:-}" ]]; then
  if [[ " ${video_exts[*]} " =~ " $ext " ]]; then
    mode=video
  elif [[ " ${audio_exts[*]} " =~ " $ext " ]]; then
    mode=audio
  else
    echo -e "${RED}Error:${RESET} Unsupported format '$ext'" >&2
    exit 1
  fi
else
  mode=video; ext=mp4
fi

# Check ffmpeg if needed
if [[ "$mode" == video ]] && ! command -v ffmpeg &>/dev/null; then
  echo -e "${RED}Error:${RESET} ffmpeg required for merging." >&2
  exit 1
fi

# Build base yt-dlp args
args=()
$download_subs && args+=(--write-auto-sub --sub-lang "$subs_lang" --embed-subs)
args+=(--output "$dest_dir/$template")

if [[ "$mode" == audio ]]; then
  args+=(-x --audio-format "$ext")
else
  valid=(144 240 360 480 720 1080)
  if [[ ! " ${valid[*]} " =~ " $resolution " ]]; then
    resolution=480
  fi
  args+=(-f "bestvideo[height<=${resolution}]+bestaudio/best[height<=${resolution}]" --merge-output-format "$ext")
fi

# Playlist processing
process_playlist() {
  set +e
  mapfile -t entries < <(
    yt-dlp --ignore-errors --flat-playlist \
      --print "%(id)s|||%(title)s" \
      --playlist-items "1-${count:-}" \
      "$source_url"
  )
  total=${#entries[@]}
  [[ $total -le 0 ]] && { echo -e "${RED}Error:${RESET} no playlist items found"; exit 1; }

  local success=0 failures=0 failed_ids=()
  for entry in "${entries[@]}"; do
    IFS='|||' read -r id title <<< "$entry"
    echo -e "${GREEN}Downloading:${RESET} ${YELLOW}$id${RESET} - ${WHITE}$title${RESET}"

    video_args=()
    for a in "${args[@]}"; do
      [[ "$a" =~ ^--playlist-items ]] && continue
      video_args+=("$a")
    done

    yt-dlp "${video_args[@]}" "https://youtu.be/$id"
    code=$?

    if [[ $code -eq 0 ]]; then
      ((success++))
    else
      ((failures++))
      failed_ids+=("$id")
      echo -e "${RED}ERROR:${RESET} $id failed (exit $code), skipping."
    fi
    echo
  done

  echo -e "\n${GREEN}Done:${RESET} $success of $total downloaded."
  if (( failures > 0 )); then
    echo -e "${RED}Failed (${failures}):${RESET}"
    for id in "${failed_ids[@]}"; do
      echo -e "  • ${YELLOW}$id${RESET}"
    done
  fi
  echo -e "Saved to: ${WHITE}$dest_dir${RESET}"
  set -e
}

# Single-video processing
process_single() {
  echo -e "${GREEN}Processing single video...${RESET}"
  if yt-dlp "${args[@]}" "$source_url"; then
    echo -e "\n${GREEN}Done!${RESET} Saved to $dest_dir"
  else
    echo -e "${RED}Error:${RESET} download failed" >&2
    exit 1
  fi
}

# Dispatch based on playlist flag
if $force_pl; then
  process_playlist
else
  process_single
fi
