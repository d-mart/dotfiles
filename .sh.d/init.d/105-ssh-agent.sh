# set up ssh-agent etc
export SSH_AUTH_SOCK="$HOME/.ssh/ssh-agent.$(hostname).sock"

# test if agent is loaded
ssh-add -l 2>/dev/null >/dev/null
local add_status=$?

if [[ $add_status == 2 ]]; then
  # If agent doesn't exist (2), start it and add identities
  ssh-agent -a "$SSH_AUTH_SOCK" > /dev/null
  ssh-add > /dev/null
elif [[ $add_status == 1 ]]; then
  # if agent exists, but no identities, add some
  ssh-add > /dev/null
else
  # it at least one identity, assume we're good to go
  #echo "using existing ssh agent"
fi
