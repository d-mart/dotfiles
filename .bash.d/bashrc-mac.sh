###
### Environment setup specific to OSX
###

export PYTHONPATH="$PYTHONPATH:/usr/local/lib/python2.7/site-packages/"
export BYOBU_PREFIX=$(brew --prefix)
unset LD_LIBRARY_PATH

# Application launchers
alias emacs="/Applications/Emacs.app/Contents/MacOS/Emacs"
alias ffx="/Applications/Firefox.app/Contents/MacOS/firefox-bin -no-remote -P"
