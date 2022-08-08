#####
# Environment and setup for bash or zsh
#####
# If not running interactively, don't do anything
[ -z "$PS1" ] && return

SCRIPT_HOME="$HOME/.sh.d"

# Load some utility functions
source "$SCRIPT_HOME/utils.sh"

# Get simplified OS type
source "$SCRIPT_HOME/get-os.sh"
export OS=$(get_os)

# host-specific shell settings that should come before general scripts
source_if_exists "$SCRIPT_HOME/shell-vars.local.sh"

# load all files in init.d that look like '000_stuff.sh', specifically
# omitting files named with leading underscore like '_000_skip_me.sh'
__init_files=($(find ${SCRIPT_HOME}/init.d -type f -name \*.sh | grep '[^_][0-9]\{3\}'))

for file in ${__init_files[@]}; do
    source "$file"
done

## general alias definitions
## See /usr/share/doc/bash-doc/examples in the bash-doc package.
source_if_exists "$SCRIPT_HOME/alias/aliases"

# host-specific shell twiddlings
source_if_exists "$SCRIPT_HOME/shell-init.local.sh"
