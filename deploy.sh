#!/usr/bin/env bash
# Install / copy repository dotFiles etc

if ((BASH_VERSINFO[0] < 4)); then
  echo "This script requires bash >= 4.0 for associative array support"
  exit 40
fi

# deploy these files and dirs.
# TODO - automate generation of this list.
fileList=".zshrc .bashrc .bash_profile .gitconfig .gitexcludes .inputrc .ackrc .Xdefaults .calcrc .gdbinit .tmux.conf .ripgreprc"
dirList=".gdb .mlocate .sh.d .hammerspoon bin"

# fetch these repositories
# Hash where the key is the target directory and the value is the git url
# e.g.  repos["foo"]="https://github.com/bar/foo"
declare -A repos=(
  # assoc arrays don't work in order - for now doing this one explicitly ["${HOME}/.oh-my-zsh"]="https://github.com/ohmyzsh/ohmyzsh"
  ["${HOME}/.bash-it"]="https://github.com/revans/bash-it"
  ["${HOME}/.oh-my-zsh/plugins/zaw"]="https://github.com/yqrashawn/zaw"
  ["${HOME}/.oh-my-zsh/plugins/zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
  ["${HOME}/.oh-my-zsh/plugins/autoswitch_virtualenv"]="https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv.git"
  ["${HOME}/.tmux/plugins/tpm"]="https://github.com/tmux-plugins/tpm"
  ["${HOME}/.tmux/plugins/tmux-yank"]="https://github.com/tmux-plugins/tmux-yank"
  ["${HOME}/.tmux/plugins/tmux-open"]="https://github.com/tmux-plugins/tmux-open"
  ["${HOME}/.tmux/plugins/tmux-fpp"]="https://github.com/tmux-plugins/tmux-fpp"
  ["${HOME}/.tmux/plugins/tmux-battery"]="https://github.com/tmux-plugins/tmux-battery"
  ["${HOME}/.tmux/plugins/tmux-cpu"]="https://github.com/tmux-plugins/tmux-cpu"
  ["${HOME}/.tmux/plugins/tmux-copycat"]="https://github.com/tmux-plugins/tmux-copycat"
)

##############################
# Set up "from" and "to" variables
##############################
srcDir=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
targetDir="$HOME"

# # for testing
# #targetDir="/tmp/test"; mkdir -p $targetDir &> /dev/null

for file in $fileList; do
  src_path="${srcDir}/${file}"
  tgt_path="${targetDir}/${file}"

  # make a backup of existing dotFiles if they are real files
  if [[ -f "$tgt_path" && ! -L "$tgt_path" ]]; then
    mv "$tgt_path" "${tgt_path}.bak"
  fi

  ln -sf "$src_path" "$tgt_path"
done

##############################
# directories
##############################

# general well-known
mkdir -p "$HOME/workspace"
mkdir -p "$HOME/experiments"
mkdir -p "$HOME/personal"

[ -L "$HOME/w" ] || ln -sf "$HOME/workspace"   "$HOME/w"
[ -L "$HOME/x" ] || ln -sf "$HOME/experiments" "$HOME/x"
[ -L "$HOME/p" ] || ln -sf "$HOME/personal"    "$HOME/p"

# linked into source-controlled
for dir in $dirList; do
  src_path="${srcDir}/${dir}"
  tgt_path="${targetDir}/${dir}"

  if [ -d "$tgt_path" ]; then
    echo "Skippping link for directory $dir - already exists"
  else
    ln -s "$src_path" "$tgt_path"
  fi
done

##############################
# directories in ~/.config
##############################
mkdir -p ~/.config
for config_dir in $(find "$srcDir/.config" -depth 1 -type d); do
  base_config_dir=$(basename "$config_dir")
  tgt_path="${targetDir}/.config/${base_config_dir}"

  if [ -d "$tgt_path" ]; then
    echo "Skipping link for directory .config/${base_config_dir} - already exists"
  else
    ln -s "$config_dir" "$tgt_path"
  fi
done

##############################
# git repos
##############################
[ -d "$HOME/.oh-my-zsh" ] || git clone --recursive "https://github.com/ohmyzsh/ohmyzsh" "$HOME/.oh-my-zsh"

for target_dir in "${!repos[@]}"; do
  repo=${repos["$target_dir"]}

  if [ -d "$target_dir" ]; then
    echo "Refreshing $repo - at $target_dir"
    pushd "$target_dir" > /dev/null
    git pull
    popd > /dev/null
  else
    echo "cloning ${repo} to ${target_dir}"
    git clone --recursive "${repo}" "${target_dir}"
  fi
done

##############################
# Some stubs for local files
##############################

local_init_file="${srcDir}/.sh.d/shell-init.local.sh"
if [ ! -e "$local_init_file" ]; then
  cat > "$local_init_file" <<EOF

touch "${HOME}/.tmux.conf.local"

#####
# Local system environment settings
#####

#export foo=bar
EOF
fi

local_aliases_file="${srcDir}/.sh.d/alias/aliases.local"
if [ ! -e "$local_aliases_file" ]; then
  cat > "$local_aliases_file" <<EOF
#####
# Local aliases
#####

# alias foo=bar
EOF
fi
