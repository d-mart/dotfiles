# asdf programming language version manager

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
