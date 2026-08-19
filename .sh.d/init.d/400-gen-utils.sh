##
## general shell niceties for day-to-day life
##

#
# reload the current shell (picks up alias/function changes without PATH bloat)
#
alias reload='exec $SHELL -l'

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

#
# the address other machines on the LAN can reach this box on
#
if [ "$OS" = "mac" ]; then
  function lan_ip() {
    local iface addr
    iface=$(route -n get default 2>/dev/null | awk '/interface:/ {print $2}')
    addr=$(ipconfig getifaddr "${iface:-en0}" 2>/dev/null)
    echo "${addr:-$(hostname)}"
  }
elif [ "$OS" = "linux" ]; then
  function lan_ip() {
    local addr
    # ask the kernel which source address it would use to reach the outside
    addr=$(ip -4 route get 1.1.1.1 2>/dev/null | sed -n 's/.*src \([0-9.]*\).*/\1/p')
    [ -z "$addr" ] && addr=$(hostname -I 2>/dev/null | awk '{print $1}')
    echo "${addr:-$(hostname)}"
  }
else
  function lan_ip() {
    hostname
  }
fi
