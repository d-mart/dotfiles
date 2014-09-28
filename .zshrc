#!/usr/bin/env zsh

# -{{{ Oh My Zsh setup
#
# Path to your oh-my-zsh configuration.
ZSH=~/.oh-my-zsh

# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme
ZSH_THEME="tjkirch_mod"
#ZSH_THEME="random"

# plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git ruby rails rvm)

source $ZSH/oh-my-zsh.sh
#
#
# }}}-

export SHELL_HOME="${HOME}/.sh.d"

source "${SHELL_HOME}/zsh-setup.sh"
