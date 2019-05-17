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

#
# list listening ports
#
if [ "$OS" = "mac" ]; then
  function lports() {
    lsof -nP -i4TCP | grep LISTEN
  }
elif [ "$OS" = "linux" ]; then
  function lports() {
    ss -tnl
  }
else
  function lports() {
    echo "unknown operation system"
  }
fi
