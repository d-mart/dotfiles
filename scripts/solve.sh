#!/bin/bash

# Lifted from http://www.linuxjournal.com/article/9891
# use 'bc' easily from command line as one liner

# 
if [ $# -lt 1 ]
then
  echo "Usage: `basename $0` {expression}"
  echo "e.g.   `basename $0` 1 + 1"
fi


bc << EOF
scale=4
$@
quit
EOF
