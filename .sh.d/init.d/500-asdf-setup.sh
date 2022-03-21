# asdf programming language version manager

# typical linux manual installation
if [ -f "$HOME/.asdf/asdf.sh" ] ; then 
  . "$HOME/.asdf/asdf.sh"

  # TODO bash --> . $HOME/.asdf/completions/asdf.bash
  # TODO zsh  --> fpath=(${ASDF_DIR}/completions $fpath)
  #               autoload -Uz compinit && compinit
fi
