##
## environment setup for git-related items
##

#
# Will return the current branch name
# Usage example: git pull origin $(current_branch)
#
function current_branch() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(git rev-parse --short HEAD 2> /dev/null) || return
  echo ${ref#refs/heads/}
}
alias cb="current_branch"

function g() {
  if [ $# -eq 0 ]; then
    git status -sb
  else
    git "$@"
  fi
}

# aliases for git
alias gb="git branch"
alias gba="git branch -a"
alias gdc="git diff --cached"
alias gpl="git pull"
alias gpu="git push"
alias gstu="git status --untracked=no"
alias gly="git log --since=\"yesterday\""
alias glp="git log --patch"
alias gsu="git submodule update"
alias gg="git grep"
alias grb="git rebase origin/$(current_branch)"
alias grbm="git rebase origin/master"
alias grbi="git rebase --interactive"
alias gpfb="git push -f origin $(current_branch)"
alias gs="git stash"
alias gsp="git stash pop"
alias gcan="git commit --amend --no-edit"
alias gpushall="git remote | xargs -n 1 git push \&"
alias gcan="git commit --amend --no-edit"

alias gfo="git fetch origin"
alias gst="git status"
alias gl="git log"
alias glg="git lg"
alias gco="git checkout"
alias gcm="git commit --message"
alias gc="git commit -v"
alias gd="git diff"
