#!/bin/bash

# temperature is 1000 - 25000
# 25000 is very blue
# 4000  is a nice warm yellow/red
# 1000  is dark-room almost red-only

TEMP=${1:-4000}


redshift -P -O "$TEMP"
