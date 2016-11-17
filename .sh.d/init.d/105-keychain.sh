#################
####### KEYCHAIN
# Clear existing broken ssh-agent environment
if [ ! -f "${SSH_AUTH_SOCK}" ]; then
  export SSH_AUTH_SOCK=""
fi

# @todo make this smarterer or dependent on os-setup above
KEYCHAIN=`which keychain 2>/dev/null`
HOSTNAME=${HOSTNAME:=$(hostname -s)}

if [ -n "${KEYCHAIN:+X}" ]; then
    # if ssh auth forwarding is enabled, use it and dont start keychain
    if [ "${SSH_AUTH_SOCK}x" = "x" ] && [ "$UID" != "0" ] ; then
        if [ -x $KEYCHAIN ] ; then
            find ~/.ssh -name \*.pub | sed -e 's/\.pub//' | xargs -- $KEYCHAIN -q -Q --lockwait 1
            if [ -f ~/.keychain/$HOSTNAME-sh ] ; then
                source ~/.keychain/$HOSTNAME-sh
            fi
        fi
    fi
fi
