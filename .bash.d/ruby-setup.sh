# shell environment setup for ruby

## general aliases for ruby
alias be='bundle exec'
alias ber='bundle exec rake'
alias rsp='bundle exec rspec -d -f doc'
alias cu='bundle exec cucumber -x'
alias cuke='cu'
alias rs='rails server'
alias rc='rails console'

## daemon control
# daemon status
alias dstat='bundle exec rake daemons:status'
# dev mode
alias dstop='bundle exec rake daemons:stop'
alias dstart='bundle exec rake daemons:start'
alias drestart='dstop; dstart'
alias dbounce='drestart'
# test mode
alias tstart='bundle exec rake daemons:test:start'
alias tstop='bundle exec rake daemons:test:stop'
alias trestart='tstop; tstart'
alias tbounce='trestart'
# resque
alias rstop='bundle exec rake daemons:resque:stop'
alias rstart='bundle exec rake daemons:resque:start'
# thingling
alias thingstop='bundle exec rake daemons:thingling:stop'
alias thingstart='bundle exec rake daemons:thingling:start'

## database
# edit last migration file
alias elm='ecl db/migrate/`ls -tr db/migrate | tail -1`'
# prepare test database
alias dbtp='bundle exec rake db:migrate db:test:prepare'

## ruby environment
export RUBY_HEAP_MIN_SLOTS=800000
export RUBY_HEAP_FREE_MIN=100000
export RUBY_HEAP_SLOTS_INCREMENT=300000
export RUBY_HEAP_SLOTS_GROWTH_FACTOR=1
export RUBY_GC_MALLOC_LIMIT=79000000

## Ruby Version Manager - source first from ~, then if
## not present, look for system-wide RVM
if [[ -s ~/.rvm/scripts/rvm ]]; then
    source ~/.rvm/scripts/rvm
elif [[ -s /usr/local/rvm/scripts/rvm ]]; then
    source /usr/local/rvm/scripts/rvm
fi
