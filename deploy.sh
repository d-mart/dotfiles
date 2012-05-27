#!/bin/bash
# Install / copy repository dotFiles etc


fileList=".bashrc .bash_aliases .bash_profile prompt.sh .gitconfig .gitexcludes .screenrc .screenrc.infotainment .inputrc .ackrc .Xdefaults .calcrc"
dirList=""
targetDir="/tmp/test"
srcDir=`pwd`

for file in $fileList
do
    # make a backup of existing dotFiles
    if [ -f $targetDir/$file ]
    then
        mv $targetDir/$file $targetDir/$file.bak
    fi

    pushd $targetDir
    ln -s $srcDir/$file $file
    popd
done

if [ -f .screenrc.local.`hostname` ]
then
    ln -s $srcDir/.screenrc.local.`hostname` $targetDir/.screenrc.local
fi

for dir in $dirList
do
    # TODO: make backup of existing folders?
    pushd $targetDir
    ln -s $srcDir/$dir $dir
    popd
done


