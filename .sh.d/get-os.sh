#!/bin/bash

# get an easy-to-use os-nam
## Example usage
# blah=$(get_os)
# echo "The OS is $blah"
function get_os () {

    local OS=""
    case $OSTYPE in
        darwin*)
            OS=mac
            ;;

        linux*)
            OS=linux
            ;;

        cygwin*)
            OS=cygwin
            ;;

        *)
            OS=unknown
            ;;
    esac

    echo $OS
}

# Determine OS platform (e.g. 'Ubuntu' or 'Centos')
# From http://www.legroom.net/2010/05/05/generic-method-determine-linux-or-unix-distribution-name
function get_distribution () {
    UNAME=$(uname | tr "[:upper:]" "[:lower:]")
    # If Linux, try to determine specific distribution
    if [ "$UNAME" == "linux" ]; then
        # If available, use LSB to identify distribution
        if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
            export DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
        # Otherwise, use release info file
    p    else
            export DISTRO=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1)
        fi
    fi
    # For everything else (or if above failed), just use generic identifier
    [ "$DISTRO" == "" ] && export DISTRO=$UNAME
    unset UNAME
    echo $DISTRO
}
