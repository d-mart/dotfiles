# asdf programming language version manager

# Install or upgrade the asdf binary to the latest release.
# Safe to run repeatedly — skips install if already on the latest version.
# Usage: asdf-install-binary [version]  (version defaults to latest)
asdf-install-binary() {
  local target_version="${1:-}"
  local install_dir="${ASDF_INSTALL_DIR:-$HOME/bin}"

  # Resolve target version
  if [ -z "$target_version" ]; then
    target_version=$(curl -fsSL "https://api.github.com/repos/asdf-vm/asdf/releases/latest" \
      | grep '"tag_name"' | head -1 | cut -d'"' -f4)
    if [ -z "$target_version" ]; then
      echo "asdf-install-binary: failed to fetch latest version" >&2
      return 1
    fi
  fi

  # Check if already on the target version
  if command -v asdf >/dev/null 2>&1; then
    local current_version
    current_version=$(asdf version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+')
    if [ "$current_version" = "$target_version" ]; then
      echo "asdf is already at $target_version"
      return 0
    fi
  fi

  # Detect platform and arch
  local os arch
  case "$(uname -s)" in
    Linux)  os="linux" ;;
    Darwin) os="darwin" ;;
    *)
      echo "asdf-install-binary: unsupported OS: $(uname -s)" >&2
      return 1
      ;;
  esac
  case "$(uname -m)" in
    x86_64)          arch="amd64" ;;
    aarch64 | arm64) arch="arm64" ;;
    *)
      echo "asdf-install-binary: unsupported arch: $(uname -m)" >&2
      return 1
      ;;
  esac

  local tarball="asdf-${target_version}-${os}-${arch}.tar.gz"
  local url="https://github.com/asdf-vm/asdf/releases/download/${target_version}/${tarball}"
  local tmp_dir
  tmp_dir=$(mktemp -d)

  echo "Installing asdf ${target_version} (${os}/${arch}) to ${install_dir}..."
  if ! curl -fsSL "$url" | tar -xz -C "$tmp_dir"; then
    echo "asdf-install-binary: download/extract failed" >&2
    rm -rf "$tmp_dir"
    return 1
  fi

  if ! install -m 755 "$tmp_dir/asdf" "$install_dir/asdf" 2>/dev/null; then
    sudo install -m 755 "$tmp_dir/asdf" "$install_dir/asdf"
  fi
  rm -rf "$tmp_dir"

  echo "Installed $(asdf version)"
}

# asdf setup - supports both Go-based (newer) and bash-based versions
# remove the second branch eventually, around mid 2026, and update all
# systems to have > 0.18
if command -v asdf >/dev/null 2>&1 && [ ! -f "$HOME/.asdf/asdf.sh" ]; then
  # New Go-based asdf
  export PATH="$HOME/.asdf/shims:$PATH"
elif [ -f "$HOME/.asdf/asdf.sh" ]; then
  # Old bash-based asdf
  . "$HOME/.asdf/asdf.sh"
fi
