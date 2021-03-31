# Note: A lot kubectl tooling is handled by the oh-my-zsh kube plugin
# including many kubectl aliases and loading autocomplete
# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/kubectl/kubectl.plugin.zsh

# teleport login
alias tli='tsh login --proxy=roadie.teleport.sh:443 --auth=google-roadie --ttl=1440'
alias tlin='tli --browser=none'
#

# list all running pods in a cluster
alias kai='kubectl get pods --all-namespaces -o jsonpath="{..image}" | tr -s "[[:space:]]" "\n" | sort | uniq -c'

# wide pod display
alias kgpow='kubectl get pods --output=wide'

function use-ctx() {
  local selected_ctx

  selected_ctx=$(kubectl config get-contexts --output=name | fzf --height=40%)

  if [ -n "$selected_ctx" ]; then
    kubectl config use-context "$selected_ctx"
  fi
}

function kshell() {
  ctx_match="$1" # single match - dev, qa, staging, production
  deployment_match="$2" # a deployment

  if [ ! "$#" -ge 1 ]; then
    echo "num args: $#"
    echo "Usage: $0 <context-matching string> <deployment-matching string> [command and args]"
    echo " e.g.: $0 qa admin-web bundle exec rails console"
    return 250
  fi

  namespace="${NAMESPACE:-roadie}"

  shift ; shift
  cmd="$@" # optional, defaults to /bin/bash

  if [ -z "$cmd" ]; then
    cmd="/bin/bash"
  fi

  ctx=$(kubectl config get-contexts --output=name | grep "$ctx_match")

  # ensure we found only one context
  num_matches=$(echo "$ctx" | wc -l)

  if [ "$num_matches" -gt 1 ]; then
    echo "ERROR - matched more than one context: [$ctx_match]\n$ctx"
    return 240
  fi

  if [ -z "$ctx" ]; then
    echo "ERROR - couldn't find matching context: $ctx_match"
    return 241
  fi

  deployment=$(kubectl get deployments --namespace="$namespace" --output=name | grep "$deployment_match")

  # ensure we found exactly one deployment
  num_matches=$(echo "$deployment" | wc -l)

  if [ "$num_matches" -gt 1 ]; then
    echo "ERROR - matched more than one deployment: [$deployment_match]\n$deployment"
    return 242
  fi

  if [ -z "$deployment" ]; then
    echo "ERROR - couldn't find matching deployment: $deployment"
    return 243
  fi

  echo "Using context    [$ctx]"
  echo "Using deployment [$deployment]"
  echo "Using command    [$cmd]"
  echo kubectl exec --namespace="$namespace" --context="$ctx" --stdin --tty "$deployment" -- "$cmd"
}
