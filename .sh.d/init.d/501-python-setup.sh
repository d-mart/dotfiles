# pip should only run if there is a virtualenv currently activated
export PIP_REQUIRE_VIRTUALENV=true
# cache pip-installed packages to avoid re-downloading
export PIP_DOWNLOAD_CACHE=$HOME/.pip/cache
# but wait, we do actually want a system-wide package
syspip() {
    PIP_REQUIRE_VIRTUALENV='' pip "$@"
}

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# This is macos-specific
__conda_setup="$('/usr/local/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
  eval "$__conda_setup"
else
  if [ -f "/usr/local/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
    . "/usr/local/Caskroom/miniconda/base/etc/profile.d/conda.sh"
  else
    export PATH="/usr/local/Caskroom/miniconda/base/bin:$PATH"
  fi
fi
unset __conda_setup
# <<< conda initialize <<<
