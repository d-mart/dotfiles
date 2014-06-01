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

# aliases for git
alias gb="git branch"
alias gba="git branch -a"
alias gca="git commit -a -v"
alias gc="git commit -v"
alias gd="git diff"
alias gdc="git diff --cached"
alias gdt="git difftool"
alias gl="git pull"
alias gp="git push"
alias gst="git status"
alias gstu="git status --untracked=no"
alias gco="git checkout"
alias gly="git log --since=\"yesterday\""
alias glp="git log --patch"
alias grb="git rebase origin/master"
alias gsu="git submodule update"
alias gg="git grep"
alias gfetch="git stash && git fetch origin && git rebase origin/master && git stash pop"
alias gs="git stash"
alias gsp="git stash pop"

alias pmb="git push dmartinez $(current_branch)"
alias pmb="git push dmartinez $(current_branch)"
