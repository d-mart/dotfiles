## docker, podman, other container-related tool and config setup

function set_docker_host() {
  local readonly podman_socket=$(podman machine inspect --format '{{ .ConnectionInfo.PodmanSocket.Path }}')
  export DOCKER_HOST="$podman_socket"
}

if command -v podman &> /dev/null; then
  alias docker=podman
  set_docker_host
fi

alias d='docker'
alias di='docker images'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias db='docker build .'
alias dr='docker run --rm --interactive --tty'
alias drl='docker run --rm --interactive --tty $(docker images -q | head -1)'

alias dc='docker compose'
alias dce='docker compose exec'
function dck() { docker compose stop "$1" ; docker compose rm -f "$1" }

# if needed...
#export DOCKER_CLIENT_TIMEOUT=120
#export COMPOSE_HTTP_TIMEOUT=120

if on_mac; then
  # podman machine setup for macOS with Apple Hypervisor
  export CONTAINERS_MACHINE_PROVIDER=applehv # for podman machine init --now
fi

export PATH=$PATH:$HOME/.rd/bin
