#!/bin/bash
# Install / copy repository dotFiles etc

# deploy these files and dirs.
fileList=".bashrc .bash_aliases .bash_profile prompt.sh .gitconfig .gitexcludes .screenrc .screenrc.infotainment .inputrc .ackrc .Xdefaults .calcrc .gdbinit .irbrc .rbrc .pryrc .tmux.conf"
dirList=".gdb .mlocate .bash.d"

# Set up "from" and "to" variables
srcDir=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
targetDir="$HOME"

# for testing
#targetDir="/tmp/test"; mkdir -p $targetDir &> /dev/null

for file in $fileList
do
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
