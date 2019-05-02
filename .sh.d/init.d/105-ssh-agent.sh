# set up ssh-agent etc
readonly agent_file="${HOME}/.ssh/ssh_auth_sock"

if [ ! -S "$agent_file" ]; then
  eval `ssh-agent`
  ln -sf "$SSH_AUTH_SOCK" "$agent_file"
fi
export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
ssh-add -l > /dev/null || ssh-add
