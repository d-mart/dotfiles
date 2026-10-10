#!/bin/bash

# Memory usage bar for tmux status bar
# Returns a single block character scaled to used memory (e.g., "▅")
#
# Uses tmux-cpu's ram_percentage.sh so the bar always agrees with the
# #{ram_percentage} number shown next to it (on both Linux and macOS).

ram_script="${HOME}/.tmux/plugins/tmux-cpu/scripts/ram_percentage.sh"

# Plugin not installed - return empty string
if [ ! -x "$ram_script" ]; then
  echo ""
  exit 0
fi

# Output looks like "42.3%"; keep just the integer part
pct=$("$ram_script" | tr -d ' ')
pct=${pct%%[.,%]*}

case "$pct" in
  '' | *[!0-9]*)
    echo ""
    exit 0
    ;;
esac

bars=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
idx=$((pct * 8 / 100))
[ "$idx" -gt 7 ] && idx=7
echo "${bars[$idx]}"
