# gdb interface script - must be used from within gdb

#### Color definitions for string prints
# Foreground
FG_BLK =    '\033[0;30m' # Black - Regular
FG_RED =    '\033[0;31m' # Red
FG_GRN =    '\033[0;32m' # Green
FG_YLW =    '\033[0;33m' # Yellow
FG_BLU =    '\033[0;34m' # Blue
FG_PUR =    '\033[0;35m' # Purple
FG_CYN =    '\033[0;36m' # Cyan
FG_WHT =    '\033[0;37m' # White
# Bold Foreground
FG_B_BLK  = '\033[1;30m' # Black - Bold
FG_B_RED  = '\033[1;31m' # Red
FG_B_GRN  = '\033[1;32m' # Green
FG_B_YLW  = '\033[1;33m' # Yellow
FG_B_BLU  = '\033[1;34m' # Blue
FG_B_PUR  = '\033[1;35m' # Purple
FG_B_CYN  = '\033[1;36m' # Cyan
FG_B_WHT  = '\033[1;37m' # White
# Underlined Foreground
FG_U_BLK  = '\033[4;30m' # Black - Underline
FG_U_RED  = '\033[4;31m' # Red
FG_U_GRN  = '\033[4;32m' # Green
FG_U_YLW  = '\033[4;33m' # Yellow
FG_U_BLU  = '\033[4;34m' # Blue
FG_U_PUR  = '\033[4;35m' # Purple
FG_U_CYN  = '\033[4;36m' # Cyan
FG_U_WHT  = '\033[4;37m' # White
# Blinking Foreground
FG_L_BLK =  '\033[5;30m' # Black - Underline
FG_L_RED =  '\033[5;31m' # Red
FG_L_GRN =  '\033[5;32m' # Green
FG_L_YLW =  '\033[5;33m' # Yellow
FG_L_BLU =  '\033[5;34m' # Blue
FG_L_PUR =  '\033[5;35m' # Purple
FG_L_CYN =  '\033[5;36m' # Cyan
FG_L_WHT =  '\033[5;37m' # White
# Background
BG_BLK =    '\033[40m'   # Black - Background
BG_RED =    '\033[41m'   # Red
BG_GRN =    '\033[42m'   # Green
BG_YLW =    '\033[43m'   # Yellow
BG_BLU =    '\033[44m'   # Blue
BG_PUR =    '\033[45m'   # Purple
BG_CYN =    '\033[46m'   # Cyan
BG_WHT =    '\033[47m'   # White
# Remove all text attributes
TXT_RESET = '\033[0m'    # Text Reset


def color_on():
    x = 1 # todo
def color_off():
    x = 2 # todo

# safety wrapper for gdb.execute.  If something in gdb.execute() fails,
# an exception is thrown.  catch and print instead
def gdb_cmd( cmd ):
    try:
        gdb.execute(cmd)
    except Exception as e:
        #print "error: exception occurred: %s" % e
        print FG_B_RED + "error: " + TXT_RESET + "exception occurred: " + FG_CYN + str(e) + TXT_RESET

#color_on()
gdb_cmd("echo Hullo. Your " + FG_B_GRN + "pythons " + TXT_RESET + "are " + FG_U_YLW + "activated" + TXT_RESET + "\n")
