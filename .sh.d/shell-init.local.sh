#####
# Local system environment settings
#####

## Disable IS extras by default
#export NO_EXTRAS=1

## Don't erase test database after test runs
#export KEEP_DB=true

## Include greenball py libes
export PYTHONPATH="$PYTHONPATH:/Users/dmartinez/proj/py_greenball/digi_xmpp:/Users/dmartinez/proj/py_greenball/digi_xmpp/upgrade_tool:/usr/local/lib/python2.7/site-packages"

# comv setup
export COMV_HOME="$HOME/proj/comv"
__shell=$(basename $SHELL)
__comv_completions="$COMV_HOME/completions/comv.$__shell"

alias comv="${COMV_HOME}/bin/comv"

if [ -f "$__comv_completions" ]; then
    source "$__comv_completions"
fi

unset LD_LIBRARY_PATH

# Application launchers
alias ffx="/Applications/Firefox.app/Contents/MacOS/firefox-bin -no-remote -P"

## 'z' for smart changing directories
#source ~/proj/z/z.sh
