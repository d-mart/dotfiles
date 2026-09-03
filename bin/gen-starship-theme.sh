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

set -euo pipefail

srcDir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
tmpl="${srcDir}/.config/starship.toml.tmpl"
target="${HOME}/.config/starship.toml"
force=0

for arg in "$@"; do
  case "$arg" in
    --force|-f) force=1 ;;
    *) echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

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
host_emoji="${emoji[$emoji_idx]}"

##############################
# Render
##############################
mkdir -p "$(dirname "$target")"
tmp=$(mktemp)
sed -e "s|__HOST_STYLE__|${host_style}|" \
    -e "s|__HOST_EMOJI__|${host_emoji}|" \
    "$tmpl" > "$tmp"

# target may be a stale symlink from before this script existed; remove it so
# we can drop a real, machine-specific file in its place.
[ -L "$target" ] && rm "$target"
mv "$tmp" "$target"

echo "Generated $target (seed=$(printf '%s' "$seed" | cut -c1-8)… color=${host_style} emoji=${host_emoji})"
