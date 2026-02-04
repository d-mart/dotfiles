# configuration and aliases for editors

# open path/to/file.ext:123 at the line 123
function ec_with_line_number() {
  if [[ $1 =~ (.*):([0-9]+)$ ]]; then
    $EMACSCLIENT -n "+${BASH_REMATCH[2]}" "${BASH_REMATCH[1]}"
  else
    $EMACSCLIENT -n "$@"
  fi
}

alias ec="ec_with_line_number"
alias e="ec_with_line_number"
alias et="$EMACSCLIENT -t"
alias ecl="$EMACSCLIENT -n -a ''"
alias eclw="$EMACSCLIENT -n -c -a ''"
alias eq='$EMACS -q -nw --eval="(setq make-backup-files nil)"'

# launch emacsclient, or failing that, emacs
export EDITOR="$EMACSCLIENT"
export VISUAL="$EMACSCLIENT -a ''"
export ALTERNATE_EDITOR="$EMACS"

# use emacs for quick su editing (via emacs-fu)
alias sue="SUDO_EDITOR=\"$EMACSCLIENT -c -a emacs\" sudoedit"
function E() {
  "$EMACSCLIENT" -c -a "$EMACS" "sudo:root@localhost:$1"
}

# for macos, there is now considerable rigamarole for letting an application
# access the LAN, as with TRAMP. It will silently just not ask if it's not
# opened the "right" way. This script assumes `emacs-plus` from brew
if on_mac; then
  function xxx_disabled_xxx_emacs() {
    APP_PATH="$(brew --prefix emacs-plus)/Emacs.app"
    SOCKET="$TMPDIR/emacs$(id -u)/server"

    # If no args, just open or bring Emacs to front
    if [[ $# -eq 0 ]]; then
      open -a "$APP_PATH"
      return 0
    fi

    # If Emacs isn't running, launch it and wait for server socket
    if ! pgrep -x Emacs >/dev/null; then
      open -a "$APP_PATH"

      for i in {1..10}; do
        if [[ -S "$SOCKET" ]]; then
          break
        fi
        sleep 1
      done
    fi

    # Try emacsclient
    if [[ -S "$SOCKET" ]]; then
      emacsclient --no-wait "$@"
    else
      # Fallback if server never started
      open -a "$APP_PATH" --args "$@"
    fi
  }
fi

# If antigravity is installed, add to PATH
if [ -d "$HOME/.antigravity/antigravity" ]; then
  export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
fi
