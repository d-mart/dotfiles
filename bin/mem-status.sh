#!/bin/bash

# Memory usage for tmux status bar
# Returns used-memory percentage plus a block character scaled to it
# (e.g., "42.3% ▄")
#
# Runs on every status-interval tick, so the Linux path is pure bash (no
# process spawns). Elsewhere it defers to tmux-cpu's ram_percentage.sh.

if [ -r /proc/meminfo ]; then
  while read -r key value _; do
    case "$key" in
      MemTotal:) total=$value ;;
      MemAvailable:) avail=$value ;;
    esac
  done < /proc/meminfo
  tenths=$(((total - avail) * 1000 / total))
  text="$((tenths / 10)).$((tenths % 10))%"
  pct=$((tenths / 10))
else
  ram_script="${HOME}/.tmux/plugins/tmux-cpu/scripts/ram_percentage.sh"

  # Plugin not installed - return empty string
  if [ ! -x "$ram_script" ]; then
    echo ""
    exit 0
  fi

  # Output looks like "42.3%"; the bar only needs the integer part
  text=$("$ram_script" | tr -d ' ')
  pct=${text%%[.,%]*}

  case "$pct" in
    '' | *[!0-9]*)
      echo ""
      exit 0
      ;;
  esac
fi

bars=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
idx=$((pct * 8 / 100))
[ "$idx" -gt 7 ] && idx=7
echo "${text} ${bars[$idx]}"
