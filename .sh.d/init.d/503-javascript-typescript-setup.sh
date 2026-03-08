# shell environment setup for javascript and typescript

# pnpm
# todo - this path is macos-specific, need to make it work on linux too
export PNPM_HOME="${HOME}/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
