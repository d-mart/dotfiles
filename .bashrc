#!/bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return


MY_SCRIPT_DIR="$HOME/.bash.d"

# Get simplified OS type
source "$MY_SCRIPT_DIR/get-os.sh"
OS=$(get_os)


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

# shell related setup
if [ -f "$MY_SCRIPT_DIR/bash-setup.sh" ]; then
    source "$MY_SCRIPT_DIR/bash-setup.sh"
fi

# git related setup
if [ -f "$MY_SCRIPT_DIR/git-setup.sh" ]; then
    source "$MY_SCRIPT_DIR/git-setup.sh"
fi

# ruby related setup
if [ -f "$MY_SCRIPT_DIR/ruby-setup.sh" ]; then
    source "$MY_SCRIPT_DIR/ruby-setup.sh"
fi

# emacs related setup
if [ -f "$MY_SCRIPT_DIR/emacs-setup.sh" ]; then
    source "$MY_SCRIPT_DIR/emacs-setup.sh"
fi

# mac-specific stuff
if [ $OS == "mac" && -f "$MY_SCRIPT_DIR/bashrc-mac.sh" ]; then
    source "$MY_SCRIPT_DIR/bashrc-mac.sh"
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
fi

# general alias definitions
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

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
export PATH=/usr/local/sbin:$PATH:~/.bash.d:~/bin:~/app


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
