#!/bin/bash

# enable color support of ls and also add handy aliases
# @todo make this dependent on linux
if [ -x /usr/bin/dircolors ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto -h'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Wine
alias win="env WINEPREFIX=\"~/.wine\" wine"

# Me likey color!
which colorgcc &> /dev/null  && alias gcc=colorgcc
which colordiff &> /dev/null && alias diff=colordiff
alias ccat=/usr/share/source-highlight/src-hilite-lesspipe.sh


# launching aliases
alias g='gedit 2>/dev/null'
# emacsclient args
# -n   don't wait for client
# -c   run a new graphical emacs client (frame)
# -t   run a console emacs client
# -a   specify alternate editor
alias ecl='emacsclient -n -a ""'
alias eclw='emacsclient -n -c -a ""'
# changed to use screen helper func below alias eclt='emacsclient -n -t -a ""'
# changed to use screen helper func below alias e='emacs --quick -nw'
alias mcom='minicom --noinit --baudrate=115200 --device'
alias mcom4='minicom --noinit --baudrate=4800 --device'
alias ta='textadept'
alias tea='~/app/tea-31.0.0/bin/tea'
alias sub=sublime-text-2
alias ejd='sudo ejabberdctl'
alias adb='/usr/local/android-sdk-linux_86/platform-tools/adb'
alias ff='find . -name'
alias ffx='firefox -no-remote -p quick'      # open 'quick' profile of firefox
# @todo make more smarterer
alias ffx='/Applications/Firefox.app/Contents/MacOS/firefox-bin -no-remote -P'

# use emacs for quick su editing (via emacs-fu)
alias sue="SUDO_EDITOR=\"emacsclient -c -a emacs\" sudoedit"
function E()
{
    emacsclient -c -a emacs "sudo:root@localhost:$1"
}


# CLI tools aliases
alias pg="ps aux | grep -v grep | grep"
alias myip="ifconfig | grep \"inet addr\" | awk -F\: '{ print \$2 }' | awk '{ print \$1 }' "
alias mem="free -m"
# use my local (home dir) mlocate database (local-locate)
alias lloc="locate --database ~/.mlocate/mlocate.db"
alias llocb="locate --database ~/.mlocate/mlocate.db --basename"

## Record of longish useful shell commands for reference
# find zero-length files older than 90 days and delete
alias rm_old_empty="find . -type f -size 0 -mtime +90 | xargs rm"

# apt aliases
alias install='sudo apt-get -y install'
alias search='apt-cache search'
alias purge='sudo apt-get purge'
alias pkginfo='apt-cache show'      # show description of package
alias whichpkg='apt-file search'    # needs apt-file update to be run to update db

# workflow shortcuts
alias tag="find . -name \*.[ch] -print | etags --filter=yes > TAGS"
alias rtag="find . -name \*.rb -print | etags --filter=yes > TAGS"

## sshfs usage: sshfs [user@]host:[dir] mountpoint [options]
## sshfs -oreconnect -p 2223 Administrator@localhost:/cygdrive/c ~/sshfs
# sshfs mount aliases removed (public github)
function ssh_umount()
{
    local __ssh_mounts=`mount | grep \`whoami\` | grep fuse.sshfs | awk '{ print $3 }'`;
    for __mount in $__ssh_mounts;
    do
        echo "Unmounting $__mount";
        fusermount -u -z $__mount;
    done
}

# print the definition of a bash function, e.g. dumpfunc ftc
alias dumpfunc="declare -f"

# a script wrapper to 'bc' command line calculator
# note: collides with /usr/bin/cal - display calendar
alias cal="solve.sh"


pause() { read -p "Press Enter to continue..." ; }

# one-liner lookup on wikiepedia, e.g. 'wp ostrich'
wp() { dig +short txt $1.wp.dg.cx ; }
# reverse dns lookup
alias rdig='dig +short -x'

# Grep shortcuts
# -r recurse directories
# -I ignore binary files
# -H print filename
# -n print line number
ftc()  { egrep -rIHn --include="*\.c" --exclude="TAGS" "$@" * ; }
fth()  { egrep -rIHn --include="*\.h" --exclude="TAGS" "$@" * ; }
ftch() { egrep -rIHn --include="*\.[ch]" --exclude="TAGS" "$@" * ; }
ftr()  { egrep -rIHn --include="*\.rb" --include="\*.feature" --exclude="TAGS" "$@" * ; }
ft()   { egrep -Rn "$@" * ; }

# See if there is a local bash_aliases and source it
if [ -f ~/.bash_aliases.local ]; then
    source ~/.bash_aliases.local
fi

# Go up directory tree X number of directories
# from http://orangesplotch.com/bash-going-up/
function up()
{
    COUNTER="$@";
    # default $COUNTER to 1 if it isn't already set
    if [[ -z $COUNTER ]]; then
        COUNTER=1
    fi
    # make sure $COUNTER is a number
    if [ $COUNTER -eq $COUNTER 2> /dev/null ]; then
        nwd=`pwd` # Set new working directory (nwd) to current directory
        # Loop $nwd up directory tree one at a time
        until [[ $COUNTER -lt 1 ]]; do
            nwd=`dirname $nwd`
            let COUNTER-=1
        done
        cd $nwd # change directories to the new working directory
    else
        # print usage and return error
        echo "usage: up [NUMBER]"
        return 1
    fi
}

# remove all compiled emacs files and then recompile them
# from article+comments at http://linuxcommando.blogspot.com/2008/06/run-emacs-in-batch-mode-to-byte-compile.html
function recompile_el()
{
    find ~/.emacs.d/ -type f -name "*.elc" | xargs rm;
    find ~/.emacs.d/ -type f -name "*.el" | awk '{print "(byte-compile-file \"" $1 "\")";}' > /tmp/runme.el
    emacs -batch -l /tmp/runme.el -kill
    rm /tmp/runme.el
}

# run the given command <n> times
# e.g.
# $ repeat 35 echo "hello"
function repeat()
{
    local __i=0
    local __count=$1
    shift
    for ((__i=1; __i <= __count; __i++))
    do
        echo "Iteration: $__i"
        $@
    done
}


###
# These funcs call the screen-helper script, which if
# called from inside a screen session, will launch
# them in a new screen window
SCREEN_HELPER=screen-helper.sh
vim()   { $SCREEN_HELPER vim $* ; }
vi()    { $SCREEN_HELPER vi $* ; }
man()   { $SCREEN_HELPER man $* ; }
info()  { $SCREEN_HELPER info $* ; }
less()  { $SCREEN_HELPER less $* ; }
watch() { $SCREEN_HELPER watch $* ; }
ssh()   { $SCREEN_HELPER ssh $*  ; }
eclt()  { $SCREEN_HELPER emacsclient -a "emacs -nw" --tty $* ; }
e()     { $SCREEN_HELPER emacs --quick -nw $* ; }
ack()   { $SCREEN_HELPER ack-grep --pager="less -R" $* ; }
hex()   { $SCREEN_HELPER vbindiff $* ; }
w3m()   { $SCREEN_HELPER w3m $* ; }
com()   { $SCREEN_HELPER minicom --noinit --baudrate 115200 --device $* ; }
comA()  { $SCREEN_HELPER minicom --noinit --baudrate 115200 --device /dev/ftdi_A $* ; }
comB()  { $SCREEN_HELPER minicom --noinit --baudrate 115200 --device /dev/ftdi_B $* ; }
comC()  { $SCREEN_HELPER minicom --noinit --baudrate 115200 --device /dev/ftdi_C $* ; }
comD()  { $SCREEN_HELPER minicom --noinit --baudrate 115200 --device /dev/ftdi_D $* ; }
