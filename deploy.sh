#!/bin/bash
# Install / copy repository dotFiles etc

# deploy these files and dirs.
# @todo - automate generation of this list.
fileList=".bashrc .bash_aliases .bash_profile prompt.sh .gitconfig .gitexcludes .screenrc .screenrc.infotainment .inputrc .ackrc .Xdefaults .calcrc .gdbinit .irbrc .rbrc .pryrc .tmux.conf"
dirList=".gdb .mlocate .sh.d .rb.d"

# fetch these repositories
# Hash where the key is the target directory and the value is the git url
# e.g.  repos["foo"]="https://github.com/bar/foo"
declare -A repos=( ["~/.oh-my-zsh"]="https://github.com/robbyrussell/oh-my-zsh"
                   ["~/.prezto"]="https://github.com/sorin-ionescu/prezto"
                   ["~/.bash-it"]="https://github.com/revans/bash-it" )

# Set up "from" and "to" variables
srcDir=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
targetDir="$HOME"

# for testing
#targetDir="/tmp/test"; mkdir -p $targetDir &> /dev/null

for file in $fileList; do
    # make a backup of existing dotFiles
    if [ -f $targetDir/$file ]
    then
        mv $targetDir/$file $targetDir/$file.bak
    fi

    pushd $targetDir > /dev/null
    ln -s $srcDir/$file $file
    popd > /dev/null
done

# files that are per-host
if [ -f .screenrc.local.`hostname` ]; then
    ln -s $srcDir/.screenrc.local.`hostname` $targetDir/.screenrc.local
fi

if [ -f .bash_aliases.local.`hostname` ]; then
    ln -s $srcDir/.bash_aliases.local.`hostname` $targetDir/.bash_aliases.local
fi

# directories
for dir in $dirList; do
    # TODO: make backup of existing folders?
    pushd $targetDir > /dev/null
    ln -s $srcDir/$dir $dir
    popd > /dev/null
done

# git repos
for target_dir in "${!repos[@]}"; do
    repo=${repos["$target_dir"]}
    echo "cloning ${repo} to ${target_dir}"
    echo git clone --recursive "${repo}" "${target_dir}"
done
