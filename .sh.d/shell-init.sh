#####
# Environment and setup for bash or zsh
#####
# If not running interactively, don't do anything
[ -z "$PS1" ] && return

SCRIPT_HOME="$HOME/.sh.d"

# Load some utility functions
source "$SCRIPT_HOME/utils.sh"

# Get simplified OS type
source "$SCRIPT_HOME/get-os.sh"
export OS=$(get_os)

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# environment variables etc
if [ -f "$SCRIPT_HOME/env-setup.sh" ]; then
    source "$SCRIPT_HOME/env-setup.sh"
fi

# git related setup
if [ -f "$SCRIPT_HOME/git-setup.sh" ]; then
    source "$SCRIPT_HOME/git-setup.sh"
fi

# ruby related setup
if [ -f "$SCRIPT_HOME/ruby-setup.sh" ]; then
    source "$SCRIPT_HOME/ruby-setup.sh"
fi

# python related setup
if [ -f "$SCRIPT_HOME/python-setup.sh" ]; then
    source "$SCRIPT_HOME/python-setup.sh"
fi

# emacs related setup
if [ -f "$SCRIPT_HOME/emacs-setup.sh" ]; then
    source "$SCRIPT_HOME/emacs-setup.sh"
fi

# tmux related setup
if [ -f "$SCRIPT_HOME/tmux-setup.sh" ]; then
    source "$SCRIPT_HOME/tmux-setup.sh"
fi

# docker setup
if [ -f "$SCRIPT_HOME/docker-setup.sh" ]; then
    source "$SCRIPT_HOME/docker-setup.sh"
fi

## general alias definitions
## See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f "$SCRIPT_HOME/alias/aliases" ]; then
    source "$SCRIPT_HOME/alias/aliases"
fi

# tmuxinator - tmux session/project management
if [ -s "$HOME/.tmuxinator/scripts/tmuxinator" ]; then
    source "$HOME/.tmuxinator/scripts/tmuxinator"
fi

if [ -f "$SCRIPT_HOME/shell-init.local.sh" ]; then
    source "$SCRIPT_HOME/shell-init.local.sh"
fi

# Source highlighting in the 'less' command
# A couple of locations - for debian or osx/brew
SRC_HILITES[1]=/usr/share/source-highlight/src-hilite-lesspipe.sh
SRC_HILITES[2]=/usr/local/bin/src-hilite-lesspipe.sh
SRC_HILITES[3]=/usr/bin/src-hilite-lesspipe.sh

for hl in "${SRC_HILITES[@]}"
do
    if [ -f $hl ]
    then
        export LESSOPEN="| $hl %s"
        break
    fi
done

#################
####### KEYCHAIN
# Clear existing broken ssh-agent environment
if [ ! -f "${SSH_AUTH_SOCK}" ]; then
  export SSH_AUTH_SOCK=""
fi

# @todo make this smarterer or dependent on os-setup above
KEYCHAIN=`which keychain 2>/dev/null`
HOSTNAME=${HOSTNAME:=$(hostname -s)}

if [ -n "${KEYCHAIN:+X}" ]; then
    # if ssh auth forwarding is enabled, use it and dont start keychain
    if [ "${SSH_AUTH_SOCK}x" = "x" ] && [ "$UID" != "0" ] ; then
        if [ -x $KEYCHAIN ] ; then
            find ~/.ssh -name \*id_\?sa -print0 | xargs -0 -- $KEYCHAIN -q -Q --lockwait 1
            if [ -f ~/.keychain/$HOSTNAME-sh ] ; then
                source ~/.keychain/$HOSTNAME-sh
            fi
        fi
    fi
fi

# Remove the garbage characters with the Unix tr command
# tr -cd '\11\12\15\40-\176' < file-with-binary-chars > clean-file
