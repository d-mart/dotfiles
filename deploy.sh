#!/usr/bin/env bash
# Install / copy repository dotFiles etc

# TODO: bail out if bash version is not new enough for associative arrays

# deploy these files and dirs.
# @todo - automate generation of this list.
fileList=".zshrc .bashrc .bash_aliases .bash_profile prompt.sh .gitconfig .gitexcludes .screenrc .screenrc.infotainment .inputrc .ackrc .Xdefaults .calcrc .gdbinit .irbrc .rbrc .pryrc .tmux.conf"
dirList=".gdb .mlocate .sh.d .rb.d"

# fetch these repositories
# Hash where the key is the target directory and the value is the git url
# e.g.  repos["foo"]="https://github.com/bar/foo"
declare -A repos=(
  ["~/.oh-my-zsh"]="https://github.com/robbyrussell/oh-my-zsh"
  #["~/.prezto"]="https://github.com/sorin-ionescu/prezto"
  ["~/.bash-it"]="https://github.com/revans/bash-it"
  ["~/.oh-my-zsh/plugins/zaw"]="https://github.com/yqrashawn/zaw"
  ["~/.oh-my-zsh/plugins/zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
)

# Set up "from" and "to" variables
srcDir=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
targetDir="$HOME"

# for testing
#targetDir="/tmp/test"; mkdir -p $targetDir &> /dev/null

for file in $fileList; do
  # make a backup of existing dotFiles
  if [ -f "${targetDir}/${file}" ]; then
    mv "${targetDir}/${file}" "${targetDir}/${file}.bak"
  fi

  pushd "$targetDir" > /dev/null
  ln -sf "${srcDir}/${file}" "$file"
  popd > /dev/null
done

# directories
for dir in $dirList; do
  pushd "$targetDir" > /dev/null
  if [ -e "$dir" ]; then
    echo "Skippping link for directory $dir - already exists"
  else
    ln -s "${srcDir}/{$dir}" "$dir"
  fi
  popd > /dev/null
done

# git repos
for target_dir in "${!repos[@]}"; do
  repo=${repos["$target_dir"]}
  if [ -d "$target_dir" ]; then
    echo "Skipping $repo - $target_dir already exists"
  else
    echo "cloning ${repo} to ${target_dir}"
    git clone --recursive "${repo}" "${target_dir}"
  fi
done
