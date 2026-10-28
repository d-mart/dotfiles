#!/usr/bin/env bash
# Render .config/starship.toml.tmpl into ~/.config/starship.toml, filling in a
# per-machine color + emoji for the [hostname] module so SSH sessions into
# different boxes are visually distinguishable at a glance.
#
# The color/emoji are derived deterministically from a stable per-machine ID
# (hardware UUID / machine-id / hostname), so re-running this on the same
# machine always produces the same theme.
#
# Usage:
#   bin/gen-starship-theme.sh            # generate only if not already generated
#   bin/gen-starship-theme.sh --force    # regenerate (e.g. after editing the .tmpl,
#                                         # or to migrate a machine still on a plain
#                                         # symlinked starship.toml from before this existed)
#   bin/gen-starship-theme.sh --emoji 🦊       # use this emoji instead of the hash-picked one
#   bin/gen-starship-theme.sh --from-tmux      # copy @status_left_icon from ~/.tmux.conf.local
#
# --emoji and --from-tmux are explicit requests, so they imply --force.

set -euo pipefail

srcDir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
tmpl="${srcDir}/.config/starship.toml.tmpl"
target="${HOME}/.config/starship.toml"
tmuxLocal="${HOME}/.tmux.conf.local"
force=0
emoji_override=""
from_tmux=0

usage() {
  cat <<'USAGE'
Usage: gen-starship-theme.sh [options]

Render .config/starship.toml.tmpl into ~/.config/starship.toml, filling in a
per-machine color + emoji for the [hostname] module so SSH sessions into
different boxes are visually distinguishable at a glance. The color/emoji are
derived deterministically from a stable per-machine ID, so re-running on the
same machine produces the same theme.

Options:
  -f, --force        Regenerate even if starship.toml was already generated.
      --emoji <e>    Use this emoji instead of the hash-picked one (implies --force).
      --from-tmux    Copy @status_left_icon from ~/.tmux.conf.local (implies --force).
                     Mutually exclusive with --emoji.
  -h, --help         Show this help and exit.
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --help|-h) usage; exit 0 ;;
    --force|-f) force=1 ;;
    --emoji)
      if [ $# -lt 2 ] || [ -z "$2" ]; then
        echo "--emoji requires a value" >&2; exit 1
      fi
      emoji_override="$2"; shift ;;
    --emoji=*) emoji_override="${1#--emoji=}" ;;
    --from-tmux) from_tmux=1 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
  shift
done

if [ -n "$emoji_override" ] && [ "$from_tmux" -eq 1 ]; then
  echo "--emoji and --from-tmux are mutually exclusive" >&2
  exit 1
fi

if [ "$from_tmux" -eq 1 ]; then
  if [ ! -f "$tmuxLocal" ]; then
    echo "tmux local config not found: $tmuxLocal" >&2
    exit 1
  fi
  # Last uncommented `set -g @status_left_icon "<icon>"` wins, like tmux would.
  emoji_override=$(sed -n -E 's/^[[:space:]]*set(-option)?[[:space:]]+-g[[:space:]]+@status_left_icon[[:space:]]+["'"'"']([^"'"'"']*)["'"'"'].*/\2/p' "$tmuxLocal" | tail -n1)
  # Drop surrounding whitespace (icons are often padded for tmux spacing).
  emoji_override=$(printf '%s' "$emoji_override" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')
  if [ -z "$emoji_override" ]; then
    echo "No @status_left_icon found in $tmuxLocal" >&2
    exit 1
  fi
fi

[ -n "$emoji_override" ] && force=1

if [ ! -f "$tmpl" ]; then
  echo "Template not found: $tmpl" >&2
  exit 1
fi

# Regenerate if forced, if nothing exists yet, or if what's there is still the
# old-style symlink straight into the repo (pre-dates this script).
if [ -e "$target" ] && [ "$force" -ne 1 ] && [ ! -L "$target" ]; then
  echo "starship.toml already generated at $target (use --force to regenerate)"
  exit 0
fi

##############################
# Stable per-machine seed
##############################
seed=""
if command -v ioreg &>/dev/null; then
  seed=$(ioreg -rd1 -c IOPlatformExpertDevice 2>/dev/null | awk -F'"' '/IOPlatformUUID/{print $4}')
fi
if [ -z "$seed" ] && [ -r /etc/machine-id ]; then
  seed=$(cat /etc/machine-id)
fi
if [ -z "$seed" ] && [ -r /var/lib/dbus/machine-id ]; then
  seed=$(cat /var/lib/dbus/machine-id)
fi
if [ -z "$seed" ]; then
  seed=$(hostname)
fi

if command -v shasum &>/dev/null; then
  hash=$(printf '%s' "$seed" | shasum -a 256 | awk '{print $1}')
elif command -v sha256sum &>/dev/null; then
  hash=$(printf '%s' "$seed" | sha256sum | awk '{print $1}')
else
  echo "Need shasum or sha256sum to derive a host theme" >&2
  exit 1
fi

##############################
# Palettes - independent slices of the hash pick a color and an emoji so
# they don't move in lockstep across machines.
##############################
colors=(
  "bold fg:#e06c75"  # red
  "bold fg:#d19a66"  # orange
  "bold fg:#e5c07b"  # yellow
  "bold fg:#98c379"  # green
  "bold fg:#2bbac5"  # teal
  "bold fg:#56b6c2"  # cyan
  "bold fg:#61afef"  # blue
  "bold fg:#528bff"  # bright blue
  "bold fg:#c678dd"  # purple
  "bold fg:#ff6ac1"  # pink
  "bold fg:#be5046"  # dark red
  "bold fg:#ffa07a"  # salmon
)

emoji=(
  "🐙" "🦊" "🐝" "🐢" "🦉" "🐧" "🦁" "🐳" "🦄" "🐺"
  "🦅" "🐿️" "🦔" "🐍" "🦖" "🐬" "🦋" "🐌" "🦂" "🐲"
)

color_idx=$(( 16#${hash:0:8} % ${#colors[@]} ))
emoji_idx=$(( 16#${hash:8:8} % ${#emoji[@]} ))
host_style="${colors[$color_idx]}"
host_emoji="${emoji_override:-${emoji[$emoji_idx]}}"

##############################
# Render
##############################
mkdir -p "$(dirname "$target")"
tmp=$(mktemp)
# Escape sed replacement metacharacters in user-supplied emoji.
host_emoji_esc=$(printf '%s' "$host_emoji" | sed -e 's/[\\&|]/\\&/g')
sed -e "s|__HOST_STYLE__|${host_style}|" \
    -e "s|__HOST_EMOJI__|${host_emoji_esc}|" \
    "$tmpl" > "$tmp"

# target may be a stale symlink from before this script existed; remove it so
# we can drop a real, machine-specific file in its place.
[ -L "$target" ] && rm "$target"
mv "$tmp" "$target"

echo "Generated $target (seed=$(printf '%s' "$seed" | cut -c1-8)… color=${host_style} emoji=${host_emoji})"
