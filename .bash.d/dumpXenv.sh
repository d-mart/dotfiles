#!/bin/bash

# Dump various environment variables to a file.  Source
# that file in e.g. a screen session that has stale
# environment variables (e.g. was initiated in a previous
# X session)

OUTFILE=~/.env

set | grep -e "^X" -e "^DBUS" -e "^SESSION_MANAGER" -e "^DISPLAY" | sed -e 's/^/export /' > $OUTFILE

# after running this script, source $OUTFILE from terminal
# with stale vars

echo "Created file $OUTFILE containing session environment data."
echo "In other terminal, "
echo " $ source $OUTFILE"

