# set up ssh-agent etc
export SSH_AUTH_SOCK="$HOME/.ssh/ssh-agent.sock"

# test if agent is loaded and functional
ssh-add -l 2>/dev/null >/dev/null
local add_status=$?

if [[ $add_status == 2 ]]; then
  # Exit code 2 means the agent socket exists but the agent isn't running
  # Remove stale socket file if it exists
  if [[ -S "$SSH_AUTH_SOCK" ]]; then
    rm -f "$SSH_AUTH_SOCK"
  fi
  # Start new agent and add identities
  ssh-agent -a "$SSH_AUTH_SOCK" > /dev/null
  ssh-add > /dev/null
elif [[ $add_status == 1 ]]; then
  # Agent exists but no identities, add some
  ssh-add > /dev/null
else
  # Agent has at least one identity, we're good to go
  #echo "using existing ssh agent"
fi

function rtmux {
  local remote_host="$1"

  autossh -M 0 -qt "$remote_host" "LC_ALL=en_US.UTF-8 tmux att || LC_ALL=en_US.UTF-8 tmux new"
}
