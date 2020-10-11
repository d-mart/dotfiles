# shell environment setup for golang

# adapted from https://github.com/kennyp/asdf-golang/issues/28
alias go-reshim='asdf reshim golang && export GOROOT="$(asdf where golang)/go"'
