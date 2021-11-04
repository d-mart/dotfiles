# Note: A lot kubectl tooling is handled by the oh-my-zsh kube plugin
# including many kubectl aliases and loading autocomplete
# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/kubectl/kubectl.plugin.zsh

# minikube
alias mk='minikube'

# teleport login
alias tli='tsh login --proxy=roadie.teleport.sh:443 --auth=google-roadie --ttl=1440'
alias tlin='tli --browser=none'
#

# list all running pods in a cluster
alias kai='kubectl get pods --all-namespaces -o jsonpath="{..image}" | tr -s "[[:space:]]" "\n" | sort | uniq -c'

# wide pod display
alias kgpow='kubectl get pods --output=wide'

# show pods' resource usage by label, e.g. podtop app=foobar
alias podtop='kubectl top pod -l'

# set default workspace
alias ns='kubectl config set-context --current --namespace'

function use-ctx() {
  search_arg="$1"
  local selected_ctx

  selected_ctx=$(kubectl config get-contexts --output=name | fzf --height=10 --query="$search_arg")

  if [ -n "$selected_ctx" ]; then
    kubectl config use-context "$selected_ctx"
  fi
}

## List all image versions running in a context (with counts)
function kgetver() {
  ctx_match="$1"

  ctx=$(_k_get-context-from-match "$ctx_match") \
     || _k_log_error "$ctx" 220 || return 220

  kubectl get pods \
          --context="$ctx" \
          --all-namespaces \
          --output=jsonpath="{.items[*].spec.containers[*].image}" 2>&1 | \
    tr ' ' '\n' | cut -d '/' -f 2 | sort | uniq -c
}

## Run an interactive command (default: bash) on a pod
function kshell() {
  ctx_match="$1" # single match - dev, qa, staging, production
  pod_match="$2" # a deployment

  if [ ! "$#" -ge 1 ]; then
    echo "num args: $#"
    echo "Usage: $0 <context-matching string> <pod-matching string> [command and args]"
    echo " e.g.: $0 qa admin-web bundle exec rails console"
    return 250
  fi

  namespace=$(_k_get-namespace)

  shift ; shift
  cmd="$@" # optional, defaults to /bin/bash

  if [ -z "$cmd" ]; then
    cmd="/bin/bash"
  fi

  ctx=$(_k_get-context-from-match "$ctx_match") \
    || _k_log_error "$ctx" $? || return 230

  pod=$(_k_get-pod-from-match "$ctx" "$pod_match") \
    || _k_log_error "$pod" $? || return 231

  echo "Using context [$ctx]"
  echo "Using pod     [$pod]"
  echo "Using command [$cmd]"

  # the /bin/bash -c $cmd is a hack - without it (just $cmd), an error is thrown that
  # "entire long commend with args" can't be found (vs expected - running "enitre" with arguments)
  # echo kubectl exec --namespace="$namespace" --context="$ctx" --stdin --tty "$pod" -- $cmd
  kubectl exec --namespace="$namespace" --context="$ctx" --stdin --tty "$pod" -- /bin/bash -c $cmd
}

###############
# helper funcs
###############
function _k_get-namespace() {
  namespace="${NAMESPACE:-roadie}"

  echo "$namespace"
}

function _k_get-context-from-match() {
  ctx_match="$1" # single match - dev, qa, staging, production

  ctx=$(kubectl config get-contexts --output=name | grep "$ctx_match")

  # ensure we found only one context
  num_matches=$(echo "$ctx" | wc -l)

  if [ "$num_matches" -gt 1 ]; then
    echo "ERROR: matched more than one context with \"$ctx_match\" :\n$ctx"
    return 240
  fi

  if [ -z "$ctx" ]; then
    echo "ERROR: couldn't find matching context: $ctx_match"
    return 241
  fi

  echo "$ctx"
}

function _k_get-deployment-from-match() {
  ctx="$1"
  deployment_match="$2"
  namespace=$(_k_get-namespace)

  deployment=$(kubectl get deployments --context="$ctx" --namespace="$namespace" --output=name |
                 sed -e 's/\.app//' |
                 grep "$deployment_match")

  # ensure we found exactly one deployment
  num_matches=$(echo "$deployment" | wc -l)

  if [ "$num_matches" -gt 1 ]; then
    echo "ERROR: matched more than one deployment with \"$deployment_match\" :\n$deployment"
    return 242
  fi

  if [ -z "$deployment" ]; then
    echo "ERROR: couldn't find matching deployment: $deployment_match"
    return 243
  fi

  echo "$deployment"
}

function _k_get-pod-from-match() {
  ctx="$1"
  pod_match="$2"
  namespace=$(_k_get-namespace)

  SHUF=shuf
  if ! command -v $SHUF &>/dev/null; then
    SHUF="head"
  fi

  pod=$(kubectl get pods --context="$ctx" --namespace="$namespace" --output=name |
          grep "$pod_match" |
          $SHUF -n 1)

  echo "$pod"
}

function _k_log_error() {
  message="$1"
  code="$2"

  echo "[$code] $message"
  return "$code"
}
