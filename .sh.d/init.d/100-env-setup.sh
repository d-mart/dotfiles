# Environment setup

# -R   raw control chars (allows source highlighting a la above)
# -S   chop long lines instead of wrapping
# -N   always show line numbers
# -#4  horiz scroll is by 4 chars
# -~   empty lines at end of doc are blank, not ~
# -i   searches ignore case unless search term contains caps
export LESS=' -RSN#4~i '
export LESS=' -R~i '

# Add some personal dirs to the path
export PATH=/usr/local/sbin:$PATH:~/.bash.d:~/bin:~/app

# Use a particular firefox profile for webdev
export SELENIUM_PROFILE_FOR_FIREFOX="selenium"

# Add local dirs to library paths
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig

# Colorful manpages
export GROFF_NO_SGR=1
function man()
{
    env LESS_TERMCAP_mb=$'\E[01;31m'   \
    LESS_TERMCAP_md=$'\E[01;38;5;74m'  \
    LESS_TERMCAP_me=$'\E[0m'           \
    LESS_TERMCAP_se=$'\E[0m'           \
    LESS_TERMCAP_so=$'\E[41m'          \
    LESS_TERMCAP_ue=$'\E[0m'           \
    LESS_TERMCAP_us=$'\E[04;38;5;146m' \
    man "$@"
}
