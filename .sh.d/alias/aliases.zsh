#!/usr/bin/env zsh

alias -g G='| grep -i' # ignore case
alias -g L='| less --chop-long-lines'
alias -g C='| wc -l'
alias -g H='| head -n 25'

# use 'git' completions also for 'g'
compdef g='git'
