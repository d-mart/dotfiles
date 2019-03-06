# shell environment setup for elixir

alias age="ag --elixir"
alias phx="iex -S mix phx.server"

export ERL_AFLAGS="-kernel shell_history enabled"
