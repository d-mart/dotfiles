## Personal settings for gdb

## command history
set history save on
set history size 10000
set history filename ~/.gdb_history

# Set confirm off (quit without warning about active process)
set confirm off

# TUI (curses interface) config
#set tui border-kind acs
#set tui active-border-mode bold
#set tui border-mode standard
#
## Print / display settings
set print array on
set print pretty on
set print union on
set print object on
set print static-members off
set print vtbl on
set print demangle on
set demangle-style gnu-v3
set print sevenbit-strings off

# fancy(er) color prompt
set prompt \033[1;34m(\033[1;36mgdb\033[1;34m) \033[0m

# display numbers in hex by default
set output-radix 0x10
#set input-radix 0x10

# These make gdb never pause in its output
set height 0
set width 0

# can't ever remember name of 'whatis' command.  Whatis it again?
define type
  whatis
end
document type
Alias for 'whatis'
end

