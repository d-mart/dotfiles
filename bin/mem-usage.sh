#!/bin/bash

# Cross-platform memory usage script for tmux status bar
# Returns format: "used/total" (e.g., "8.5G/16.0G")

case "$(uname)" in
  Darwin)
    # macOS: Calculate App Memory like Activity Monitor
    # App Memory = (Anonymous pages - Purgeable pages) * page_size
    # Plus Wired Memory for total "used" memory
    page_size=$(vm_stat | head -1 | grep -o '[0-9]*' | head -1)
    app_mem=$(vm_stat | awk -v ps="$page_size" '
            /Anonymous pages/ {anon = $3}
            /Pages purgeable/ {purg = $3}
            /Pages wired/ {wired = $4}
            END {printf "%.1fG", ((anon - purg) + wired) * ps / 1024^3}')
    total=$(sysctl -n hw.memsize | awk '{printf "%.1fG", $1 / 1024^3}')
    echo "${app_mem}/${total}"
    ;;
  Linux)
    # Linux: Use free command
    free -h | awk '/Mem/ {print $3 "/" $2}'
    ;;
  *)
    # Unknown OS - return empty string
    echo ""
    ;;
esac
