#!/usr/bin/env BASH
## Little papercut functions

on_mac()
{
    return $(uname -a | grep -iq darwin)
}

# Return the first argument, or stdin if first arg is missing or '-'
first_or_stdin()
{
    local result
    if [[ $1 == "" ]] || [[ $1 == "-" ]]; then
        read
        result="$REPLY"
    else
        result="$1"
    fi

    echo "$result"
}

## quickly create a tarball of a dir and place it in /tmp
# TODO: Check for correct path
# TODO: Make it work for current directory
# usage:
#    qbak <directory>
qbak()
{
    DATE_STR=$(date "+%Y_%m_%d_%H_%M_%S")
    SRC_DIR=${1:-"."}
    TARGET_NAME=$(cd $SRC_DIR && basename $(pwd))
    TAR_NAME="${TARGET_NAME}_${DATE_STR}.tgz"
    # TMP_DIR="${TMPDIR:-/tmp}"
    TMP_DIR="/tmp"
    # mkdir -p "${TMP_DIR}"
    TAR_PATH="${TMP_DIR}/${TAR_NAME}"
    tar czf "${TAR_PATH}" "${TARGET_NAME}/"
    echo "Snapshotted to ${TAR_PATH}"
    ls -la "${TAR_PATH}"
}

## ssh to a vagrant box by name, with normal ssh, e.g.
# vssh my_vagrant_vm1 /run/some/command
vssh()
{
    # vm name in Vagrantfile is first arg
    BOX=$1
    # shift vm name off of arg list
    shift
    # create
    SSH_CFG="/tmp/${BOX}_ssh_config_$(date | sed -e 's/[: ]/_/g')"
    # store the generated SSH config from vagrant
    vagrant ssh-config $BOX > "$SSH_CFG"
    # ssh to machine
    ssh -F "$SSH_CFG" $@ $BOX
    # delete temporary ssh config
    rm "$SSH_CFG"
}

# display and possibly add a dir to the path
path()
{
    # Add any args to the path
    for dir in "$@"; do
        export PATH="$PATH:$dir"
    done

    # Display the path to show modifications, if any
    echo "PATH is $PATH"
}

# load up ssh-agent
sshag()
{
    source <(ssh-agent)
    # Add identities to ssh-agent
    find ~/.ssh -name "id_?sa" -exec ssh-add '{}' \;
}

# make a random passwd
randpw()
{
    __pw_helper "[:print:]" ${1:-32}
    echo;
}

# alpha-numeric random password
randan()
{
    __pw_helper "a-zA-Z0-9" ${1:-32}
    echo;
}

# make a postgres password hash
# $1 = user
# $2 = cleartext pass
pghash()
{
    # the openssl installed on mac does not prepend openssl's output with anything, whereas
    # on linux there is something like '(stdin=) ' before the hash
    if on_mac
    then
        SED_PATTERN='^'      # to just prepend output with 'md5'
    else
        SED_PATTERN='.* '    # to replace anything and a space with 'md5'
    fi

    echo "$1$2" | openssl md5 | sed -e "s/$SED_PATTERN/md5/g"
}

# find an available port
#
avail_port()
{
    local port=$1
    : ${port:=25678}

    # BSD netstat shows IP.PORT instead of IP:PORT
    if on_mac; then
        port=$(avail_port_bsd $port)
    else
        while netstat -tuna | egrep -q "^\w+\s+\w+\s+\w+\s+(\w+\.){3}\w+:${port}"
        do
            port=$(( $port + 1))
        done
    fi
    echo $port
}

avail_port_bsd()
{
    local port=$1

    while netstat -p tcp -p udp -n | grep -q "^(tcp|udp)\w*\s+\w+\s+\w+\s+\S+.${port}"
    do
        port=$(( $port + 1))
    done

    echo $port
}

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

# (un)pause pids
# @todo take param instead of hardcoding ffx
# @todo extract the loop and pass the kill flag into a common helper
function pause_pids()
{
    local __pid_regex=$1
    __signal_pids "${__pid_regex}" SIGSTOP
}

function unpause_pids()
{
    local __pid_regex=$1
    __signal_pids "${__pid_regex}" SIGCONT
}

###########
# Helpers #
###########
__pw_helper()
{
    # osx (or other unicode env) requires the LC_CTYPE=C
    < /dev/urandom LC_CTYPE=C tr -cd "${1:-0-9A-F}" | head -c${2:-32}
}

__signal_pids()
{
    local __pid_match="$1"
    local __pid_signal="$2"

    for __pid in $(pgrep -i "${__pid_match}")
    do
        local __process_name=$(ps -p "${__pid}" -o comm=)
        echo "Sending ${__pid_signal} to ${__process_name} with pid ${__pid}."
        echo kill "-${__pid_signal}" "${__pid}"
    done

}
