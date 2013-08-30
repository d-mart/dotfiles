#!/bin/bash
# screen-helper.sh - Runs commands in new GNU screen windows
#                    if called from within a screen session.
# dm - adapted from intarwebs - lost link

# These funcs call the screen-helper script, which if
# called from inside a screen session, will launch
# them in a new screen window
# SCREEN_HELPER=screen-helper.sh
# vim()   { $SCREEN_HELPER vim $* ; }
# vi()    { $SCREEN_HELPER vi $* ; }
# man()   { $SCREEN_HELPER man $* ; }
# info()  { $SCREEN_HELPER info $* ; }
# less()  { $SCREEN_HELPER less $* ; }
# watch() { $SCREEN_HELPER watch $* ; }
# ssh()   { $SCREEN_HELPER ssh $*  ; }
# eclt()  { $SCREEN_HELPER emacsclient -a "emacs -nw" --tty $* ; }
# e()     { $SCREEN_HELPER emacs --quick -nw $* ; }
# ack()   { $SCREEN_HELPER ack-grep --pager="less -R" $* ; }
# hex()   { $SCREEN_HELPER vbindiff $* ; }
# w3m()   { $SCREEN_HELPER w3m $* ; }
# com()   { $SCREEN_HELPER minicom --noinit --baudrate 115200 --device $* ; }
# comA()  { $SCREEN_HELPER minicom --noinit --baudrate 115200 --device /dev/ftdi_A $* ; }
# comB()  { $SCREEN_HELPER minicom --noinit --baudrate 115200 --device /dev/ftdi_B $* ; }
# comC()  { $SCREEN_HELPER minicom --noinit --baudrate 115200 --device /dev/ftdi_C $* ; }
# comD()  { $SCREEN_HELPER minicom --noinit --baudrate 115200 --device /dev/ftdi_D $* ; }


# function to shorten an argument
shorten ()
{
    SHORT_LEN=7
    if [ $1 ]
    then
        echo $1 | cut -c1-$SHORT_LEN
    else
        #if there wasn't an arg, punt and try to display the command
        echo $cmd | cut -c1-$SHORT_LEN
    fi
}



# Get the current directory and the name of command
wd=`pwd`
cmd=$1
shift

# for some commands, namely less, we might
# pipe data into it, e.g. cat somthing.txt | less
# Intercepting the command will mess this up, so we
# guess that if there are no args, we'll redirect the
# input to this script to the input of the command
# in question.  However, we can't (that I know of)
# get the generator of that input from this script,
# i.e. the 'cat something.txt'
PIPED_INPUT="NO"

# We can tell if we are running inside screen by looking
# for the STY environment variable.
# If $STY not set, just run the command as it is
# if $STY is set, check for certain special ones we
# want to run in a new screen window with a modified title
if [ -z "$STY" ]; then
        $cmd $*
else
    # Screen needs to change directory so that
    # relative file names are resolved correctly.
    screen -X chdir $wd

    # if the command is 'ssh', loop thru all the args
    # to find the first one that doesn't start with a
    # dash '-'.  Use as the title the found string *after*
    # the '@'.  Net result:
    # ssh -x -y -z someone@myhost --> title=myhost
    # NOTE:
    # * this will break for e.g. ssh -p 8080 myhost
    # * but can't just use last arg either
    #   e.g. ssh myhost runthiscommand
    # * also can't count on there being an '@'
    case $cmd in
        "ssh")
            # force term. xterm-256color is a safe base for everthing i've used
            # but sometimes an inherited term such as screen-bce-256color causes
            # complaints on lighter systems
            cmd="TERM=xterm-256color $cmd"
            # attempt to determine hostname for screen window title
            for arg in $*
            do
                if [[ $arg != \-* ]]  # if arg doesn't start with a dash
                then
                    title=""${arg##*@}""
                    title=$(shorten $title)
                    break
                fi
            done
            ;;

        # for this group, we're more interested in the second argument,
        # e.g. what are we ack-ing, less-ing, info-ing, etc.
        "info" | "man")
            title="m:$(shorten $1)"
            ;;

        # ack - get last argument which is the pattern being searched for
        "ack" | "ack-grep")
            # @todo - this is fragile - programmatically search for last arg
            title="a:$(shorten $2)"
            ;;

        # commands where we're interested in a filename -
        # strip off any leading directory
        "watch")
            title=$(shorten $(basename $1))
            ;;

        "less")
            cmd="less -R"  # allow control chars (syntax hilite)
            if [[ $1 == "" ]]
            then
                # no filename was specified.  Assume something was piped to less
                PIPED_INPUT="YES"
                title="<stdin>"
                # @todo work in progress. possibly inside the PIPED_INPUT==YES
                # below, redirect <&0 to another named pipe, or maybe a
                # temporary file, and call command on it
                $cmd <&0
            else
                title="l:$(shorten $(basename $1))"
            fi
            ;;

        # Just display the (length-limited) command name
        *)
            title=$(shorten $cmd)
    esac

    # create a new screen window in the current session
    # with the derived window title
    if [[ $PIPED_INPUT == "YES" ]]
    then
        #screen -X screen -t "$title" cat <&0 | $cmd
        true  # dummy command for now
    else
        screen -X echo "running screen -X screen -t \"$title\" $cmd $*"
        screen -X screen -t "$title" $cmd $*
    fi
fi
