if (hash exa 2> /dev/null ) ; then
  alias ll="exa --long --all --sort=modified"
  alias la="exa --long --all --sort=modified"
  alias l2="exa --long --all --tree --level=2 --sort=modified --color-scale"
  alias l3="exa --long --all --tree --level=3 --sort=modified --color-scale"
  alias lln="exa --long --all --sort=name"
  alias lt="exa --long --all --sort=extension"
fi
