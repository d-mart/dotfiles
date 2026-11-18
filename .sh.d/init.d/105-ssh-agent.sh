# set up ssh-agent etc
export SSH_AUTH_SOCK="$HOME/.ssh/ssh-agent.sock"

# Full probe + recovery, exactly as tuned: ssh-add -l exit 2 means the socket
# exists but the agent isn't running (drop stale socket, start a new agent,
# add identities); exit 1 means the agent is up but has no identities (add
# them); exit 0 means at least one identity is loaded. Kept as a function so
# it can be re-run by hand after e.g. `ssh-add -D`.
__ssh_agent_ensure() {
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
    :
  fi
}

# Lazy startup check: skip the ssh-add -l roundtrip when the agent can be
# trusted without forking anything -- the socket is newer than the current
# boot (so it can't be a stale leftover from a previous boot) and a previous
# probe verified identities are loaded (stamp file). Anything else falls back
# to the full probe. zsh-only fast path; bash always runs the full probe.
__ssh_agent_check() {
  local stamp="$HOME/.ssh/.agent-identities-loaded"
  if [ -n "$ZSH_NAME" ] && [ -f "$stamp" ] && [ -S "$SSH_AUTH_SOCK" ] \
     && zmodload zsh/datetime 2>/dev/null && zmodload zsh/stat 2>/dev/null \
     && [ -n "$EPOCHREALTIME" ]; then
    local uptime boot sock_mtime
    read uptime _ < /proc/uptime 2>/dev/null
    sock_mtime=$(zstat +mtime "$SSH_AUTH_SOCK" 2>/dev/null)
    if [ -n "$uptime" ] && [ -n "$sock_mtime" ]; then
      boot=$(( ${EPOCHREALTIME%.*} - ${uptime%.*} ))
      if (( sock_mtime >= boot )); then
        return 0
      fi
    fi
  fi
  __ssh_agent_ensure
  # remember the outcome so the next shell can take the fast path
  if ssh-add -l >/dev/null 2>&1; then
    touch "$stamp"
  else
    rm -f "$stamp"
  fi
}
__ssh_agent_check
unset -f __ssh_agent_check

# (rtmux/autotmux now live in 200-tmux.sh)
