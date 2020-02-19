alias d='docker'
alias di='docker images'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias db='docker build .'
alias dr='docker run --rm --interactive --tty'
alias drl='docker run --rm --interactive --tty $(docker images -q | head -1)'

alias dc='docker-compose'
alias dce='docker-compose exec'
function dck() { docker-compose stop "$1" ; docker-compose rm -f "$1" }

# if needed...
#export DOCKER_CLIENT_TIMEOUT=120
#export COMPOSE_HTTP_TIMEOUT=120

# TODO Maybe helps tmux run
# docker run -i -t ... sh -c "exec >/dev/tty 2>/dev/tty </dev/tty && /usr/bin/screen -s /bin/bash"
