# shell environment setup for ruby

# Call 'bundle exec' like this:
bundle_exec="bundle exec"
# bundle_exec="BUNDLE_GEMFILE=\"Gemfile.dm\" bundle exec"

## general aliases for ruby
alias be="$bundle_exec"
alias ber="$bundle_exec rake"
alias rsp="LOG_LEVEL=DEBUG $bundle_exec rspec --color -f doc"
alias rspf="rsp --fail-fast"
alias cu="$bundle_exec cucumber -x"
alias cuke="cu"
alias rs="$bundle_exec rails server"
alias rc="$bundle_exec rails console"

alias agr="ag --ruby"
alias rgr="rg --type ruby"

## daemon control
# daemon status
alias dstat="$bundle_exec rake daemons:status"
# dev mode
alias dstop="$bundle_exec rake daemons:stop"
alias dstart="$bundle_exec rake daemons:start"
alias drestart="dstop; dstart"
alias dbounce="drestart"
# test mode
alias tstart="$bundle_exec rake daemons:test:start"
alias tstop="$bundle_exec rake daemons:test:stop"
alias trestart="tstop; tstart"
alias tbounce="trestart"
# resque
alias rstop="$bundle_exec rake daemons:resque:stop"
alias rstart="$bundle_exec rake daemons:resque:start"
# thingling
alias thingstop="$bundle_exec rake daemons:thingling:stop"
alias thingstart="$bundle_exec rake daemons:thingling:start"

## database
# edit last migration file
function elm() { ecl db/migrate/`ls -tr db/migrate | tail -1`; }
# prepare test database
alias dbtp="$bundle_exec rake db:migrate db:test:prepare"

## serve current directoryv via HTTP
function serve {
  port="${1:-3000}"
  ruby -run -e httpd . -p $port
}

## share a single file over HTTP on the LAN: woof report.zip [port]
## runs until interrupted; see bin/woof.py for the original woof, which
## hands the file out a fixed number of times and then exits on its own
function woof {
  local target="${1:?usage: woof FILE [PORT]}"
  local port="${2:-8000}"

  if [ ! -f "$target" ]; then
    echo "woof: not a readable file: $target" >&2
    return 1
  fi

  local name dir docroot
  name=$(basename -- "$target")
  dir=$(cd -- "$(dirname -- "$target")" && pwd) || return 1

  # WEBrick can only serve a directory, so link the one file into a throwaway
  # docroot -- using the file's own directory would expose every sibling too
  docroot=$(mktemp -d "${TMPDIR:-/tmp}/woof.XXXXXX") || return 1
  if ! ln -s "$dir/$name" "$docroot/$name"; then
    rm -rf "$docroot"
    return 1
  fi

  echo "woof: http://$(lan_ip):${port}/${name}"
  # subshell so the trap cleans up on ctrl-c without touching the parent shell
  (
    trap 'rm -rf "$docroot"' EXIT HUP INT TERM
    ruby -run -e httpd "$docroot" -p "$port" -b 0.0.0.0
  )
}

## Ruby Version Manager - source first from ~, then if
## not present, look for system-wide RVM
if [[ -s ~/.rvm/scripts/rvm ]]; then
    source ~/.rvm/scripts/rvm
elif [[ -s /usr/local/rvm/scripts/rvm ]]; then
    source /usr/local/rvm/scripts/rvm
fi
