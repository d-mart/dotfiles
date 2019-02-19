##
## general shell niceties for day-to-day life
##

#
# make a directory and change to it
#
function mkcd() {
  dir="$1"
  mkdir -p "$dir" && cd "$dir"
}
