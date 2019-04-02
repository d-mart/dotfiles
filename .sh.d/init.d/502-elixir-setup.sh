# shell environment setup for elixir

alias age="ag --elixir"
alias phx="iex -S mix phx.server"
alias mt="iex -S mix test --trace"

export ERL_AFLAGS="-kernel shell_history enabled"
