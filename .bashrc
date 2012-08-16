#!/bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
# ... or force ignoredups and ignorespace
export HISTCONTROL=ignoreboth
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)

# CDPATH - like PATH but for CD command.  When
# typing 'cd mydir' look in all these directories,
# not just pwd
#export CDPATH='~/proj:~/.emacs.d'

# HISTIGNORE - keep uninteresting (or sensitive)
# commands out of bash history
export HISTIGNORE="[bf]g:exit:ls:pwd:top:w:history"     #"[bf]g:exit:ls:ls *:cd *:top:w"

# append to the history file, don't overwrite it
shopt -s histappend

# correct minor misspellings (transpositions etc) in CD commands
shopt -s cdspell

# extended glob
#This will give you ksh-88 egrep-style extended pattern matching or, in other words, turbo-charged pattern matching within bash. The available operators are:
#    ?(pattern-list)
#Matches zero or one occurrence of the given patterns
#    *(pattern-list)
#Matches zero or more occurrences of the given patterns
#    +(pattern-list)
#Matches one or more occurrences of the given patterns
#    @(pattern-list)
#Matches exactly one of the given patterns
#    !(pattern-list)
#Matches anything except one of the given patterns
#Here's an example. Say, you wanted to install all RPMs in a given directory, except those built for the noarch architecture. You might use something like this:
#    rpm -Uvh /usr/src/RPMS/!(*noarch*)
#These expressions can be nested, too, so if you wanted a directory listing of all non PDF and PostScript files in the current directory, you might do this:
#    ls -lad !(*.p@(df|s))
shopt -s extglob

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# automatically cd into a directory if the command entered doesn't exists
shopt -s autocd

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac



if [ `whoami` == "root" ]; then 
    # prompt for root
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    # user prompt - git/rails/etc
    source ~/prompt.sh
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# Ruby Version Manager
if [ - f /etc/profile.d/rvm.sh ]; then
    . /etc/profile.d/rvm.sh
fi

# rsense - ruby completion for emacs and vim
export RSENSE_HOME="~/proj/stuff/utils/rsense/"

# Setup default system editor.  In this case,
# launch emacsclient, or failing that, emacs
export ALTERNATE_EDITOR=emacs
export EDITOR=emacsclient
export VISUAL=emacsclient

# Source highlighting in the 'less' command
# this path points to default debian location of
# the source-highlight script - adjust as nec.
SRC_HILITE=/usr/share/source-highlight/src-hilite-lesspipe.sh
[ -f $SRC_HILITE ] && export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"

# -R   raw control chars (allows source highlighting a la above)
# -S   chop long lines instead of wrapping
# -N   always show line numbers
# -#4  horiz scroll is by 4 chars
# -~   empty lines at end of doc are blank, not ~
# -i   searches ignore case unless search term contains caps
export LESS=' -RSN#4~i '

# Add some personal dirs to the path
export PATH=$PATH:~/.bash.d:~/bin:~/app


#################
####### KEYCHAIN
# Clear existing broken ssh-agent environment
#
if [ ! -f "${SSH_AUTH_SOCK}" ] ; then
  export SSH_AUTH_SOCK=""
fi

# if ssh auth forwarding is enabled, use it and dont start keychain
KEY_LIST="$( find ~/.ssh -name "id_*sa" -print )"
if [ "${SSH_AUTH_SOCK}x" == "x" ] && [ "$UID" != "0" ] ; then
    if [ -x /usr/bin/keychain ] ; then
       /usr/bin/keychain -q -Q --lockwait 1 $KEY_LIST
       if [ -f ~/.keychain/$HOSTNAME-sh ] ; then
          source ~/.keychain/$HOSTNAME-sh
       fi
    fi
fi

# Remove the garbage characters with the Unix tr command
# tr -cd '\11\12\15\40-\176' < file-with-binary-chars > clean-file
