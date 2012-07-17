## Per-project gdb init file.
## Drop in e.g. dir that contains project Makefile
## as '.gdbinit' and gdb will run this file in addtion
## to ~/.gdb

# Put breakpoints to test with in here. Called below
define __setupBreakpoints
  delete breakpoints

  break nvm.c:373
  break nvm.c:2893
end


# define a command to restart the target program
#        Load target and set args
define reload
  file build/imod.exe
  set args -Basic
  __setupBreakpoints
  start
end

# write a recognizable string to a memory location
# TODO: make length variable. This one is 247 chars
define paintmem
  call sprintf($arg0, "%s", "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789AABBCCDDEEFFGGHHIIJJKKLLMMNNOOPPQQRRSSTTUUVVWWXXYYZZaabbccddeeffgghhiijjkkllmmnnooppqqrrssttuuvvwwxxyyzz112233445566778899AAABBBCCCDDDEEEFFFGGGHHHIIIJJJKKKLLLMMMNNNOOOPPPQQQRRRSSSTTTUU")
end

####
# Run these commands when starting gdb - main entry point
set listsize 20
reload  # load target, set args, etc

continue
