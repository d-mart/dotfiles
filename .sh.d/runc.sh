#!/bin/bash

#
# Run a .c file as a script
#
# $ cat foo.c
# #!/usr/bin/env runc.sh
#
# #include <stdio.h>
# void main(void) { printf("Hello, World!\n"); }
#
# $ chmod u+x foo.c
# $ ./foo.c
# Hello, World!
#

LANG="c"
#LANG="c++"

TMPFILE=$(mktemp /tmp/runc_XXXXXX) || exit 1
sed -n '2,$p' "$@" | gcc -o $TMPFILE -x $LANG - && $TMPFILE
rm -f $TMPFILE
