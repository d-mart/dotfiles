# gdb interface script - must be used from within gdb

class Hello(gdb.Command):
    """Typical hello world: hello NAME
 
Print "hello NAME" where NAME is the argument.  This command is for
demonstrating of creating new command in Python."""
 
    def __init__(self):
        # "hello" below is the actual new gdb command
        gdb.Command.__init__(self, "hello", gdb.COMMAND_OBSCURE)
 
    def invoke(self, arg, from_tty):
        print "hello, %s!" % arg

Hello()

