# Load Linux Homebrew environment if available.
[ "${OS:-}" != "linux" ] && return 0

if [ -x "$HOME/.linuxbrew/bin/brew" ]; then
  eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
elif [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  eval "$("/home/linuxbrew/.linuxbrew/bin/brew" shellenv)"
fi
