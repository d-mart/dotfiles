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
