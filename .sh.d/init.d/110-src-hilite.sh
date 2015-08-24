# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

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
