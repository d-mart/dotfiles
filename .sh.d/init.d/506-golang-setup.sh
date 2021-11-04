# shell environment setup for golang
GOPATH="$HOME/go"
PATH="$PATH:$GOPATH/bin"

# adapted from https://github.com/kennyp/asdf-golang/issues/28
alias go-reshim='asdf reshim golang && export GOROOT="$(asdf where golang)/go"'

# Note to self
# go get github.com/pcarrier/gauth
