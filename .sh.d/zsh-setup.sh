#!/usr/bin/env zsh
#####
# zsh config options
#####

## Correction Options
# don't offer typo corrections, e.g. ivm --> vim
unsetopt correct
unsetopt correct_all
# if there are no matches for globs, leave them alone and execute the command
setopt no_nomatch

## Completion Options
# Cursor moves to word end after completion is inserted
set always_to_end

## History Options
# edit recalled history before running
set hist_verify
# add commands to .history immediately
set inc_append_history
# don't share history across sessions # setopt no_share_history
unsetopt share_history
# don't put multiple copies of same command in history
setopt hist_ignore_dups
# expire duplicate history entries first (not really needed with hist_ignore_dups)
setopt hist_expire_dups_first
# timestamp with command histories
setopt extended_history

## cd / navigation options
# automatically push dirs onto a stack
setopt auto_pushd

# allow inline comments to be entered
setopt interactivecomments

# send a SIGCONT to `disown`-ed processes
setopt auto_continue

# exit status of a pipe is the rightmost that *failed*
setopt pipefail

source "${SHELL_HOME}/shell-init.sh"

if (which direnv > /dev/null) ; then
  eval "$(direnv hook zsh)"
fi
