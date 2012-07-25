# ~/.bash_profile: executed by bash for login shells.

# To pick up the latest recommended .bash_profile content,
# look in /etc/defaults/etc/skel/.bash_profile

# Modifying /etc/skel/.bash_profile directly will prevent
# setup from updating it.

# source the system wide bashrc if it exists
if [ -e /etc/bash.bashrc ] ; then
  source /etc/bash.bashrc
fi

# source system bash completion files
if [ -e /etc/bash_completion ] ; then
    source /etc/bash_completion
fi

# source the users bashrc if it exists
if [ -e "${HOME}/.bashrc" ] ; then
  source "${HOME}/.bashrc"
fi

# Set PATH so it includes several private dirs if they exist
DIRLIST="app bin .bash.d"
for dir in $DIRLIST; do
    if [ -d "${HOME}/bin" ] ; then
        PATH=${HOME}/bin:${PATH}
    fi
done

# Set MANPATH so it includes users' private man if it exists
if [ -d "${HOME}/man" ]; then
  MANPATH=${HOME}/man:${MANPATH}
fi

# Set INFOPATH so it includes users' private info if it exists
if [ -d "${HOME}/info" ]; then
  INFOPATH=${HOME}/info:${INFOPATH}
fi

