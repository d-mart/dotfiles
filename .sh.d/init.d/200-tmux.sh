# shell environment setup for tmux

# print the active tmux session name
tmux_active_session()
{
    tmux list-sessions | \grep attached | cut -f 1 -d ':'
}
