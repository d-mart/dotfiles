# Load Linux Homebrew environment if available.
[ "${OS:-}" != "linux" ] && return 0

__brew_bin=""
if [ -x "$HOME/.linuxbrew/bin/brew" ]; then
  __brew_bin="$HOME/.linuxbrew/bin/brew"
elif [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  __brew_bin="/home/linuxbrew/.linuxbrew/bin/brew"
fi

if [ -n "$__brew_bin" ]; then
  # `brew shellenv` spawns brew itself (~100ms per shell). Cache its output and
  # only regenerate when the brew binary changes (upgrades rewrite it).
  __brew_cache="${XDG_CACHE_HOME:-$HOME/.cache}/brew-shellenv.sh"
  __brew_sig="$(stat -c '%Y:%s' "$__brew_bin" 2>/dev/null)"
  __brew_hdr=""
  [ -r "$__brew_cache" ] && IFS= read -r __brew_hdr < "$__brew_cache"
  if [ -n "$__brew_sig" ] && [ "$__brew_hdr" = "# sig:$__brew_sig" ]; then
    source "$__brew_cache"
  else
    mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}"
    __brew_tmp="$__brew_cache.$$"
    if printf '# sig:%s\n' "$__brew_sig" > "$__brew_tmp" \
       && "$__brew_bin" shellenv >> "$__brew_tmp" 2>/dev/null; then
      mv "$__brew_tmp" "$__brew_cache"
      source "$__brew_cache"
    else
      rm -f "$__brew_tmp"
      eval "$("$__brew_bin" shellenv)"
    fi
    unset __brew_tmp
  fi
fi
unset __brew_bin __brew_cache __brew_sig __brew_hdr
