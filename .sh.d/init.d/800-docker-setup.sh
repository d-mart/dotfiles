alias d='docker'
alias di='docker images'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias db='docker build .'
alias drl='docker run --rm -it $(docker images -q | head -1)'

alias dc='docker-compose'
alias dm='docker-machine'


# TODO Maybe helps tmux run
# docker run -i -t ... sh -c "exec >/dev/tty 2>/dev/tty </dev/tty && /usr/bin/screen -s /bin/bash"
