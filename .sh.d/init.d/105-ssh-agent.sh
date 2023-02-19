# set up ssh-agent etc
export SSH_AUTH_SOCK="$HOME/.ssh/ssh-agent.$(hostname).sock"

# test if agent is loaded
ssh-add -l 2>/dev/null >/dev/null

if [ $? -ge 2 ]; then
  ssh-agent -a "$SSH_AUTH_SOCK" > /dev/null
fi

# Load local identities
ssh-add > /dev/null
