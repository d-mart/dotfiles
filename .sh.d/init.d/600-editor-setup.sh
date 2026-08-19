# configuration and aliases for editors

# shell-init sources init.d *before* alias/aliases, where $EMACS and
# $EMACSCLIENT get their fallback values -- so resolve them here, or every
# alias and export below expands to nothing on a machine that doesn't already
# have them in the environment.
#
# Version-agnostic on purpose: picks the newest emacs-plus@NN that is actually
# installed, so bumping majors needs no edit here. Globs the keg directly rather
# than asking brew, which keeps this working on a box where brew isn't on PATH.
function __resolve_emacs() {
  local __prefix __keg=""

  # Emacs exports EMACS=t into some subshells, and a stale override can point at
  # a path that no longer exists. Either would be honoured as a real value by the
  # :=-assignments below, so drop anything that isn't actually runnable.
  command -v "${EMACS:-}" >/dev/null 2>&1 || EMACS=""
  command -v "${EMACSCLIENT:-}" >/dev/null 2>&1 || EMACSCLIENT=""
  [ -d "${EMACS_APP:-}" ] || EMACS_APP=""

  for __prefix in "${HOMEBREW_PREFIX:-}" /opt/homebrew /usr/local \
                  /home/linuxbrew/.linuxbrew "${HOME}/.linuxbrew"; do
    [ -n "${__prefix}" ] && [ -d "${__prefix}/opt" ] || continue
    # sort on the numeric field after '@' so @31 beats @30
    __keg=$(find "${__prefix}/opt" -maxdepth 1 -name 'emacs-plus@*' 2>/dev/null \
              | sort -t@ -k2 -rn | head -1)
    [ -n "${__keg}" ] && break
  done

  if [ -n "${__keg}" ] && [ -x "${__keg}/bin/emacs" ]; then
    : "${EMACS:=${__keg}/bin/emacs}"
    : "${EMACSCLIENT:=${__keg}/bin/emacsclient}"
    [ -d "${__keg}/Emacs.app" ] && : "${EMACS_APP:=${__keg}/Emacs.app}"
  fi

  # a plain build on PATH covers linux and any mac without emacs-plus
  command -v emacs >/dev/null 2>&1 && : "${EMACS:=emacs}"
  command -v emacsclient >/dev/null 2>&1 && : "${EMACSCLIENT:=emacsclient}"

  # last resort on mac: an app bundle someone dropped in /Applications
  if on_mac && [ -d "/Applications/Emacs.app" ]; then
    : "${EMACS_APP:=/Applications/Emacs.app}"
    : "${EMACS:=/Applications/Emacs.app/Contents/MacOS/Emacs}"
    : "${EMACSCLIENT:=/Applications/Emacs.app/Contents/MacOS/bin/emacsclient}"
  fi

  # never leave these empty -- a bare name at least gives a usable error
  : "${EMACS:=emacs}"
  : "${EMACSCLIENT:=emacsclient}"

  export EMACS EMACSCLIENT
  [ -n "${EMACS_APP:-}" ] && export EMACS_APP
}
__resolve_emacs

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
# opened the "right" way. Needs the .app bundle, not the bare binary.
if on_mac; then
  function xxx_disabled_xxx_emacs() {
    APP_PATH="${EMACS_APP}"
    SOCKET="$TMPDIR/emacs$(id -u)/server"

    if [[ -z "$APP_PATH" ]]; then
      echo "no Emacs.app found; set EMACS_APP in shell-vars.local.sh" >&2
      return 1
    fi

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
      "$EMACSCLIENT" --no-wait "$@"
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
