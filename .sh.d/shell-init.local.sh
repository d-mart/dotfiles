#####
# Local system environment settings
#####

# comv setup
export COMV_HOME="$HOME/proj/comv"
__shell=$(basename $SHELL)
__comv_completions="$COMV_HOME/completions/comv.$__shell"

alias comv="${COMV_HOME}/bin/comv"

if [ -f "$__comv_completions" ]; then
    source "$__comv_completions"
fi

unset LD_LIBRARY_PATH

# Application launchers
alias ffx="/Applications/Firefox.app/Contents/MacOS/firefox-bin -no-remote -P"

## 'z' for smart changing directories
#source ~/proj/z/z.sh

hash fasd > /dev/null && eval "$(fasd --init auto)"

# set enterprise URL for gist gem - post gists from cli
export GITHUB_URL="https://github.comverge.com"

# asdf setup
source /usr/local/opt/asdf/asdf.sh

# fzf stuff
fzf_dir="/usr/local/Cellar/fzf/0.17.4/shell"
source_if_exists "$fzf_dir/completion.zsh"
source_if_exists "$fzf_dir/key-bindings.zsh"
