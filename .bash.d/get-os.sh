#!/bin/bash

# get an easy-to-use os-name

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


## Example usage
# blah=$(get_os)
# echo "The OS is $blah"

