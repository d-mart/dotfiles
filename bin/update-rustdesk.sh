#!/usr/bin/env bash
# update-rustdesk.sh
# Installs/updates RustDesk from the latest GitHub release .deb.

set -euo pipefail

FORCE=0
CHECK_ONLY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--force) FORCE=1 ;;
    -c|--check) CHECK_ONLY=1 ;;
    -h|--help)
      echo "Usage: $(basename "$0") [-c|--check] [-f|--force]"
      echo "  -c, --check    Only report whether an update is available"
      echo "  -f, --force    Reinstall even if already up to date"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

case "$(dpkg --print-architecture)" in
  amd64) arch=x86_64 ;;
  arm64) arch=aarch64 ;;
  *) echo "Unsupported architecture: $(dpkg --print-architecture)" >&2; exit 1 ;;
esac

latest=$(curl -fsSL https://api.github.com/repos/rustdesk/rustdesk/releases/latest \
  | grep -Po '"tag_name":\s*"\K[^"]+' || true)
if [[ -z "$latest" ]]; then
  echo "Failed to fetch latest RustDesk release." >&2
  exit 1
fi

# Only count the package as installed if dpkg says so (not just config files left behind).
current=""
if [[ "$(dpkg-query -W -f='${db:Status-Abbrev}' rustdesk 2>/dev/null)" == ii* ]]; then
  current=$(dpkg-query -W -f='${Version}' rustdesk)
fi

if [[ "$current" == "$latest" && "$FORCE" -eq 0 ]]; then
  echo "RustDesk is already up to date ($current)."
  exit 0
fi

if [[ "$CHECK_ONLY" -eq 1 ]]; then
  echo "Update available: ${current:-none} -> $latest"
  exit 0
fi

echo "Updating RustDesk: ${current:-none} -> $latest"
tmp=$(mktemp -d -t rustdesk-update-XXXXXX)
trap 'rm -rf "$tmp"' EXIT

deb="$tmp/rustdesk-${latest}-${arch}.deb"
curl -fL --progress-bar -o "$deb" \
  "https://github.com/rustdesk/rustdesk/releases/download/${latest}/rustdesk-${latest}-${arch}.deb"
# _apt can't read a 0700 mktemp dir; let it see the file so apt doesn't warn about unsandboxed download.
chmod 755 "$tmp"
chmod 644 "$deb"
sudo apt install -y "$deb"

echo "RustDesk is now at $(dpkg-query -W -f='${Version}' rustdesk)."
