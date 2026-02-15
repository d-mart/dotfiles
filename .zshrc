#!/usr/bin/env zsh

# If emacs/tramp etc are connecting, offer dumb prompts / setup
[[ $TERM == "dumb" ]] && unsetopt zle && PS1='$ ' && return


## Don't load omz if within claude code
if [[ -z "${CLAUDECODE}" ]]; then

  # plugins can be found in ~/.oh-my-zsh/plugins/*)
  # Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
  # Example format: plugins=(rails git textmate ruby lighthouse)
  plugins=(
    # asdf
    brew
    eza
    fzf
    git
    kubectl
    ruby
    z
    zaw
    zsh-syntax-highlighting
    autoswitch_virtualenv
  )
  # -{{{ Oh My Zsh setup
  #
  # Path to your oh-my-zsh configuration.
  ZSH=~/.oh-my-zsh

  # Look in ~/.oh-my-zsh/themes/
  # Optionally, if you set this to "random", it'll load a random theme
  ZSH_THEME="re5et"

  if [ -n "$INSIDE_EMACS" ]; then
    plugins=("${(@)a:#zsh-syntax-highlighting}")
    # there is support for detecting being inside emacs which willl do this
    # but it is colliding with my $EMACS var.
    # See https://github.com/robbyrussell/oh-my-zsh/blob/master/lib/termsupport.zsh#L12
    export DISABLE_AUTO_TITLE=true
    ZSH_THEME="robbyrussell"
  fi

  ZSH_HIGHLIGHT_HIGHLIGHTERS=( main brackets pattern cursor )

  source $ZSH/oh-my-zsh.sh
  #
  #
  # }}}-
fi # CLAUDECODE

export SHELL_HOME="${HOME}/.sh.d"

source "${SHELL_HOME}/zsh-setup.sh"

# use starship prompt over O-M-Z if it's present
if [ -x "$(command -v starship)" ]; then
  eval "$(starship init zsh)"
fi

export PATH="/usr/local/bin:$PATH"

# Added by Antigravity
export PATH="/Users/dmartinez/.antigravity/antigravity/bin:$PATH"
