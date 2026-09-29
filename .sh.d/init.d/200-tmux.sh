# shell environment setup for tmux

# print the active tmux session name
tmux_active_session()
{
  tmux list-sessions | \grep attached | cut -f 1 -d ':'
}

#
# ssh to a host (via autossh, so the connection survives naps/network flaps)
# and land in tmux there: attach to an existing session, or start a fresh one.
#
# The remote's tmux may be on PATH (linux, or a login shell) or only in
# homebrew's prefix (mac over a non-login ssh), so each step is tried both ways
# before giving up and creating a session.
#
# Any leading arguments are handed to ssh; the host must come last:
#   autotmux my_host
#   autotmux -D 10080 -L 6789:localhost:6789 my_host
#
function autotmux() {
  if [ $# -lt 1 ]; then
    echo "usage: autotmux [ssh args...] host" >&2
    return 1
  fi

  local brew_tmux="/opt/homebrew/bin/tmux"
  local ssh_args=()

  # everything but the final argument belongs to ssh
  while [ $# -gt 1 ]; do
    ssh_args+=("$1")
    shift
  done
  local remote_host="$1"

  local remote_cmd="export LC_ALL=en_US.UTF-8; \
tmux att || $brew_tmux att || tmux new || $brew_tmux new"

  if command -v autossh >/dev/null 2>&1; then
    # a random high port keeps concurrent autossh monitors from colliding
    autossh -M "$((RANDOM % 1000 + 40000))" -qt "${ssh_args[@]}" "$remote_host" "$remote_cmd"
  else
    ssh -qt "${ssh_args[@]}" "$remote_host" "$remote_cmd"
  fi
}

# long-standing muscle memory
alias rtmux='autotmux'
