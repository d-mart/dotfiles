#!/usr/bin/env zsh
#####
# zsh config options
#####

# don't offer typo corrections, e.g. ivm --> vim
unsetopt correct
unsetopt correct_all

# allow inline comments to be entered
setopt interactivecomments

# don't share history across sessions # setopt no_share_history
unsetopt share_history

# don't put multiple copies of same command in history
setopt hist_ignore_dups

# timestamp with command histories
setopt extended_history

# if there are no matches for globs, leave them alone and execute the command
setopt no_nomatch

# automatically push dirs onto a stack
setopt auto_pushd

source "${SHELL_HOME}/shell-init.sh"
