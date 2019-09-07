# shell environment setup for elixir

alias rge="rg --type elixir"
alias phx="iex -S mix phx.server"
alias mt="mix test"
alias mtd="iex -S mix test --trace" # "debug"

export ERL_AFLAGS="-kernel shell_history enabled"
