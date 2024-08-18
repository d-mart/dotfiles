if (hash eza 2> /dev/null ) ; then
  alias ll="eza --long --all --sort=modified"
  alias la="eza --long --all --sort=modified"
  alias l2="eza --long --all --tree --level=2 --sort=modified --color-scale"
  alias l3="eza --long --all --tree --level=3 --sort=modified --color-scale"
  alias lln="eza --long --all --sort=name"
  alias lt="eza --long --all --sort=extension"
fi
