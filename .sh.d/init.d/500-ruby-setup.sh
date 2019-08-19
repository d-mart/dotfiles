# shell environment setup for ruby

# Call 'bundle exec' like this:
bundle_exec="bundle exec"
# bundle_exec="BUNDLE_GEMFILE=\"Gemfile.dm\" bundle exec"

## general aliases for ruby
alias be="$bundle_exec"
alias ber="$bundle_exec rake"
alias rsp="LOG_LEVEL=DEBUG $bundle_exec rspec --color -f doc"
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

## Ruby Version Manager - source first from ~, then if
## not present, look for system-wide RVM
if [[ -s ~/.rvm/scripts/rvm ]]; then
    source ~/.rvm/scripts/rvm
elif [[ -s /usr/local/rvm/scripts/rvm ]]; then
    source /usr/local/rvm/scripts/rvm
fi
