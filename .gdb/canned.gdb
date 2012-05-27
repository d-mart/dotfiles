##### DM - Removed sections and modified some of following pre-canned .gdbinit #####

# INSTALL INSTRUCTIONS: save as ~/.gdbinit
#
# DESCRIPTION: A user-friendly gdb configuration file.
#
# REVISION : 7.3 (16/04/2010)
#
# CONTRIBUTORS: mammon_, elaine, pusillus, mong, zhang le, l0kit,
#               truthix the cyberpunk, fG!, gln
#
# FEEDBACK: https://www.reverse-engineering.net
#           The Linux Area
#           Topic: "+HCU's .gdbinit Version 7.1 -- humble announce"
#           http://reverse.put.as
#
# NOTES: 'help user' in gdb will list the commands/descriptions in this file
#        'context on' now enables auto-display of context screen
#
# MAC OS X NOTES: If you are using this on Mac OS X, you must either attach gdb to a process
#                 or launch gdb without any options and then load the binary file you want to analyse with "exec-file" option
#                 If you load the binary from the command line, like $gdb binary-name, this will not work as it should
#                 For more information, read it here http://reverse.put.as/2008/11/28/apples-gdb-bug/
#
#				  UPDATE: This bug can be fixed in gdb source. Refer to http://reverse.put.as/2009/08/10/fix-for-apples-gdb-bug-or-why-apple-forks-are-bad/
#						  and http://reverse.put.as/2009/08/26/gdb-patches/ (if you want the fixed binary for i386)
#
# CHANGELOG:
#
#	Version 7.3 (16/04/2010)
#	  Support for 64bits targets. Default is 32bits, you should modify the variable or use the 32bits or 64bits to choose the mode.
#		I couldn't find another way to recognize the type of binary… Testing the register doesn't work that well.
#	  TODO: fix objectivec messages and stepo for 64bits
#
#   Version 7.2.1 (24/11/2009)
#	  Another fix to stepo (0xFF92 missing)
#
#   Version 7.2 (11/10/2009)
#	  Added the smallregisters function to create 16 and 8 bit versions from the registers EAX, EBX, ECX, EDX
#	  Revised and fixed all the dumpjump stuff, following Intel manuals. There were some errors (thx to rev who pointed the jle problem).
#	  Small fix to stepo command (missed a few call types)
#
#   Version 7.1.7
#     Added the possibility to modify what's displayed with the context window. You can change default options at the gdb options part. For example, kernel debugging is much slower if the stack display is enabled...
#     New commands enableobjectivec, enablecpuregisters, enablestack, enabledatawin and their disable equivalents (to support realtime change of default options)
#     Fixed problem with the assemble command. I was calling /bin/echo which doesn't support the -e option ! DUH ! Should have used bash internal version.
#     Small fixes to colours...
#     New commands enablesolib and disablesolib . Just shortcuts for the stop-on-solib-events fantastic trick ! Hey... I'm lazy ;)
#     Fixed this: Possible removal of "u" command, info udot is missing in gdb 6.8-debian . Doesn't exist on OS X so bye bye !!!
#     Displays affected flags in jump decisions
#
#   Version 7.1.6
#     Added modified assemble command from Tavis Ormandy (further modified to work with Mac OS X) (shell commands used use full path name, working for Leopard, modify for others if necessary)
#     Renamed thread command to threads because thread is an internal gdb command that allows to move between program threads
#
#   Version 7.1.5 (04/01/2009)
#     Fixed crash on Leopard ! There was a If Else condition where the else had no code and that made gdb crash on Leopard (CRAZY!!!!)
#     Better code indention
#
#   Version 7.1.4 (02/01/2009)
#     Bug in show objective c messages with Leopard ???
#     Nop routine support for single address or range (contribution from gln [ghalen at hack.se])
#     Used the same code from nop to null routine
#
#   Version 7.1.3 (31/12/2008)
#     Added a new command 'stepo'. This command will step a temporary breakpoint on next instruction after the call, so you can skip over
#     the call. Did this because normal commands not always skip over (mainly with objc_msgSend)
#
#   Version 7.1.2 (31/12/2008)
#     Support for the jump decision (will display if a conditional jump will be taken or not)
#
#   Version 7.1.1 (29/12/2008)
#     Moved gdb options to the beginning (makes more sense)
#     Added support to dump message being sent to msgSend (easier to understand what's going on)
#
#   Version 7.1
#     Fixed serious (and old) bug in dd and datawin, causing dereference of
#     obviously invalid address. See below:
#     gdb$ dd 0xffffffff
#     FFFFFFFF : Cannot access memory at address 0xffffffff
#
#   Version 7.0
#     Added cls command.
#     Improved documentation of many commands.
#     Removed bp_alloc, was neither portable nor usefull.
#     Checking of passed argument(s) in these commands:
#       contextsize-stack, contextsize-data, contextsize-code
#       bp, bpc, bpe, bpd, bpt, bpm, bhb,...
#     Fixed bp and bhb inconsistencies, look at * signs in Version 6.2
#     Bugfix in bhb command, changed "break" to "hb" command body
#     Removed $SHOW_CONTEXT=1 from several commands, this variable
#     should only be controlled globally with context-on and context-off
#     Improved stack, func, var and sig, dis, n, go,...
#     they take optional argument(s) now
#     Fixed wrong $SHOW_CONTEXT assignment in context-off
#     Fixed serious bug in cft command, forgotten ~ sign
#     Fixed these bugs in step_to_call:
#       1) the correct logging sequence is:
#          set logging file > set logging redirect > set logging on
#       2) $SHOW_CONTEXT is now correctly restored from $_saved_ctx
#     Fixed these bugs in trace_calls:
#       1) the correct logging sequence is:
#          set logging file > set logging overwrite >
#          set logging redirect > set logging on
#       2) removed the "clean up trace file" part, which is not needed now,
#          stepi output is properly redirected to /dev/null
#       3) $SHOW_CONTEXT is now correctly restored from $_saved_ctx
#     Fixed bug in trace_run:
#       1) $SHOW_CONTEXT is now correctly restored from $_saved_ctx
#     Fixed print_insn_type -- removed invalid semicolons!, wrong value checking,
#     Added TODO entry regarding the "u" command
#     Changed name from gas_assemble to assemble_gas due to consistency
#     Output from assemble and assemble_gas is now similar, because i made
#     both of them to use objdump, with respect to output format (AT&T|Intel).
#     Whole code was checked and made more consistent, readable/maintainable.
#
#   Version 6.2
#     Add global variables to allow user to control stack, data and code window sizes
#     Increase readability for registers
#     Some corrections (hexdump, ddump, context, cfp, assemble, gas_asm, tips, prompt)
#
#   Version 6.1-color-user
#     Took the Gentoo route and ran sed s/user/user/g
#
#   Version 6.1-color
#     Added color fixes from
#       http://gnurbs.blogsome.com/2006/12/22/colorizing-mamons-gdbinit/
#
#   Version 6.1
#     Fixed filename in step_to_call so it points to /dev/null
#     Changed location of logfiles from /tmp  to ~
#
#   Version 6
#     Added print_insn_type, get_insn_type, context-on, context-off commands
#     Added trace_calls, trace_run, step_to_call commands
#     Changed hook-stop so it checks $SHOW_CONTEXT variable
#
#   Version 5
#     Added bpm, dump_bin, dump_hex, bp_alloc commands
#     Added 'assemble' by elaine, 'gas_asm' by mong
#     Added Tip Topics for aspiring users ;)
#
#   Version 4
#     Added eflags-changing insns by pusillus
#     Added bp, nop, null, and int3 patch commands, also hook-stop
#
#   Version 3
#     Incorporated elaine's if/else goodness into the hex/ascii dump
#
#   Version 2
#     Radix bugfix by elaine
#
#   TODO:
#     Add dump, append, set write, etc commands
#     Add more tips !


# __________________gdb options_________________

# set to 1 to enable 64bits target by default (32bit is the default)
set $64BITS = 0

# set to 1 to enable ARM platform by default (0: x86 is the default, 1: arm)
set $ARM = 0

# Display instructions in Intel format
#set disassembly-flavor intel

set $SHOW_CONTEXT   = 0
set $SHOW_NEST_INSN = 0

set $CONTEXTSIZE_STACK = 6
set $CONTEXTSIZE_DATA  = 8
set $CONTEXTSIZE_CODE  = 8

# set to 0 to remove display of objectivec messages (default is 1)
set $SHOWOBJECTIVEC = 0
# set to 0 to remove display of cpu registers (default is 1)
set $SHOWCPUREGISTERS = 0
# set to 1 to enable display of stack (default is 0)
set $SHOWSTACK = 0
# set to 1 to enable display of data window (default is 0)
set $SHOWDATAWIN = 0


# __________________end gdb options_________________

# ______________window size control___________
define contextsize-stack
    if $argc != 1
        help contextsize-stack
    else
        set $CONTEXTSIZE_STACK = $arg0
    end
end
document contextsize-stack
Set stack dump window size to NUM lines.
Usage: contextsize-stack NUM
end


define contextsize-data
    if $argc != 1
        help contextsize-data
    else
        set $CONTEXTSIZE_DATA = $arg0
    end
end
document contextsize-data
Set data dump window size to NUM lines.
Usage: contextsize-data NUM
end


define contextsize-code
    if $argc != 1
        help contextsize-code
    else
        set $CONTEXTSIZE_CODE = $arg0
    end
end
document contextsize-code
Set code window size to NUM lines.
Usage: contextsize-code NUM
end




# _____________breakpoint aliases_____________
define bpl
    info breakpoints
end
document bpl
List all breakpoints.
end

define bp
    if $argc != 1
        help bp
    else
        break $arg0
    end
end
document bp
Set breakpoint.
Usage: bp LOCATION
LOCATION may be a line number, function name, or "*" and an address.

To break on a symbol you must enclose symbol name inside "".
Example:
bp "[NSControl stringValue]"
Or else you can use directly the break command (break [NSControl stringValue])
end


define bpc
    if $argc != 1
        help bpc
    else
        clear $arg0
    end
end
document bpc
Clear breakpoint.
Usage: bpc LOCATION
LOCATION may be a line number, function name, or "*" and an address.
end


define bpe
    if $argc != 1
        help bpe
    else
        enable $arg0
    end
end
document bpe
Enable breakpoint with number NUM.
Usage: bpe NUM
end


define bpd
    if $argc != 1
        help bpd
    else
        disable $arg0
    end
end
document bpd
Disable breakpoint with number NUM.
Usage: bpd NUM
end


define bpt
    if $argc != 1
        help bpt
    else
        tbreak $arg0
    end
end
document bpt
Set a temporary breakpoint.
Will be deleted when hit!
Usage: bpt LOCATION
LOCATION may be a line number, function name, or "*" and an address.
end


define bpm
    if $argc != 1
        help bpm
    else
        awatch $arg0
    end
end
document bpm
Set a read/write breakpoint on EXPRESSION, e.g. *address.
Usage: bpm EXPRESSION
end


define bhb
    if $argc != 1
        help bhb
    else
        hb $arg0
    end
end
document bhb
Set hardware assisted breakpoint.
Usage: bhb LOCATION
LOCATION may be a line number, function name, or "*" and an address.
end




# ______________process information____________
define argv
    show args
end
document argv
Print program arguments.
end


define stack
    if $argc == 0
        info stack
    end
    if $argc == 1
        info stack $arg0
    end
    if $argc > 1
        help stack
    end
end
document stack
Print backtrace of the call stack, or innermost COUNT frames.
Usage: stack <COUNT>
end


define fr
    info frame
    info args
    info locals
end
document fr
Print stack frame, args, locals.
end



define reg
 # arm platform
 if ($ARM == 1)
    printf "r0 :"
    printf " 0x%08X  ", $r0
    printf "r1 :"
    printf " 0x%08X  ", $r1
    printf "r2 :"
    printf " 0x%08X  ", $r2
    printf "r3 :"
    printf " 0x%08X  ", $r3
    printf "r4 :"
    printf " 0x%08X\n", $r4
    printf "r5 :"
    printf " 0x%08X  ", $r5
    printf "r6 :"
    printf " 0x%08X  ", $r6
    printf "r7 :"
    printf " 0x%08X  ", $r7
    printf "r8 :"
    printf " 0x%08X  ", $r8
    printf "r9 :"
    printf " 0x%08X\n", $r9
    printf "r10:"
    printf " 0x%08X  ", $r10
    printf "r11:"
    printf " 0x%08X  ", $r11
    printf "r12:"
    printf " 0x%08X\n", $r12
    printf "sp :"
    printf " 0x%08X  ", $sp
    printf "lr :"
    printf " 0x%08X  ", $lr
    printf "pc :"
    printf " 0x%08X  ", $pc
 else
    # x86 platform
    if ($64BITS == 1)
    # 64bits stuff
        printf "  "
        echo \033[32m
        printf "RAX:"
        echo \033[0m
        printf " 0x%016lX  ", $rax
        echo \033[32m
        printf "RBX:"
        echo \033[0m
        printf " 0x%016lX  ", $rbx
        echo \033[32m
        printf "RCX:"
        echo \033[0m
        printf " 0x%016lX  ", $rcx
        echo \033[32m
        printf "RDX:"
        echo \033[0m
        printf " 0x%016lX  ", $rdx
        echo \033[1m\033[4m\033[31m
        flags
        echo \033[0m
        printf "  "
        echo \033[32m
        printf "RSI:"
        echo \033[0m
        printf " 0x%016lX  ", $rsi
        echo \033[32m
        printf "RDI:"
        echo \033[0m
        printf " 0x%016lX  ", $rdi
        echo \033[32m
        printf "RBP:"
        echo \033[0m
        printf " 0x%016lX  ", $rbp
        echo \033[32m
        printf "RSP:"
        echo \033[0m
        printf " 0x%016lX  ", $rsp
        echo \033[32m
        printf "RIP:"
        echo \033[0m
        printf " 0x%016lX\n  ", $rip
        echo \033[32m
        printf "R8 :"
        echo \033[0m
        printf " 0x%016lX  ", $r8
        echo \033[32m
        printf "R9 :"
        echo \033[0m
        printf " 0x%016lX  ", $r9
        echo \033[32m
        printf "R10:"
        echo \033[0m
        printf " 0x%016lX  ", $r10
        echo \033[32m
        printf "R11:"
        echo \033[0m
        printf " 0x%016lX  ", $r11
        echo \033[32m
        printf "R12:"
        echo \033[0m
        printf " 0x%016lX\n  ", $r12
        echo \033[32m
        printf "R13:"
        echo \033[0m
        printf " 0x%016lX  ", $r13
        echo \033[32m
        printf "R14:"
        echo \033[0m
        printf " 0x%016lX  ", $r14
        echo \033[32m
        printf "R15:"
        echo \033[0m
        printf " 0x%016lX\n  ", $r15
        echo \033[32m
        printf "CS:"
        echo \033[0m
        printf " %04X  ", $cs
        echo \033[32m
        printf "DS:"
        echo \033[0m
        printf " %04X  ", $ds
        echo \033[32m
        printf "ES:"
        echo \033[0m
        printf " %04X  ", $es
        echo \033[32m
        printf "FS:"
        echo \033[0m
        printf " %04X  ", $fs
        echo \033[32m
        printf "GS:"
        echo \033[0m
        printf " %04X  ", $gs
        echo \033[32m
        printf "SS:"
        echo \033[0m
        printf " %04X", $ss
        echo \033[0m
    # 32bits stuff
    else
        printf "  "
        echo \033[32m
        printf "EAX:"
        echo \033[0m
        printf " 0x%08X  ", $eax
        echo \033[32m
        printf "EBX:"
        echo \033[0m
        printf " 0x%08X  ", $ebx
        echo \033[32m
        printf "ECX:"
        echo \033[0m
        printf " 0x%08X  ", $ecx
        echo \033[32m
        printf "EDX:"
        echo \033[0m
        printf " 0x%08X  ", $edx
        echo \033[1m\033[4m\033[31m
        flags
        echo \033[0m
        printf "  "
        echo \033[32m
        printf "ESI:"
        echo \033[0m
        printf " 0x%08X  ", $esi
        echo \033[32m
        printf "EDI:"
        echo \033[0m
        printf " 0x%08X  ", $edi
        echo \033[32m
        printf "EBP:"
        echo \033[0m
        printf " 0x%08X  ", $ebp
        echo \033[32m
        printf "ESP:"
        echo \033[0m
        printf " 0x%08X  ", $esp
        echo \033[32m
        printf "EIP:"
        echo \033[0m
        printf " 0x%08X\n  ", $eip
        echo \033[32m
        printf "CS:"
        echo \033[0m
        printf " %04X  ", $cs
        echo \033[32m
        printf "DS:"
        echo \033[0m
        printf " %04X  ", $ds
        echo \033[32m
        printf "ES:"
        echo \033[0m
        printf " %04X  ", $es
        echo \033[32m
        printf "FS:"
        echo \033[0m
        printf " %04X  ", $fs
        echo \033[32m
        printf "GS:"
        echo \033[0m
        printf " %04X  ", $gs
        echo \033[32m
        printf "SS:"
        echo \033[0m
        printf " %04X", $ss
        echo \033[0m
    end
    # call smallregisters
        smallregisters
    # display conditional jump routine
        if ($64BITS == 1)
        printf "\t\t\t\t"
        end
 end
    dumpjump
    printf "\n"
end
document reg
Print CPU registers.
end

define smallregisters
 if ($64BITS == 1)
#64bits stuff
	# from rax
	set $eax = $rax & 0xffffffff
	set $ax = $rax & 0xffff
	set $al = $ax & 0xff
	set $ah = $ax >> 8
	# from rbx
	set $bx = $rbx & 0xffff
	set $bl = $bx & 0xff
	set $bh = $bx >> 8
	# from rcx
	set $ecx = $rcx & 0xffffffff
	set $cx = $rcx & 0xffff
	set $cl = $cx & 0xff
	set $ch = $cx >> 8
	# from rdx
	set $edx = $rdx & 0xffffffff
	set $dx = $rdx & 0xffff
	set $dl = $dx & 0xff
	set $dh = $dx >> 8
	# from rsi
	set $esi = $rsi & 0xffffffff
	set $si = $rsi & 0xffff
	# from rdi
	set $edi = $rdi & 0xffffffff
	set $di = $rdi & 0xffff
#32 bits stuff
 else
	# from eax
	set $ax = $eax & 0xffff
	set $al = $ax & 0xff
	set $ah = $ax >> 8
	# from ebx
	set $bx = $ebx & 0xffff
	set $bl = $bx & 0xff
	set $bh = $bx >> 8
	# from ecx
	set $cx = $ecx & 0xffff
	set $cl = $cx & 0xff
	set $ch = $cx >> 8
	# from edx
	set $dx = $edx & 0xffff
	set $dl = $dx & 0xff
	set $dh = $dx >> 8
	# from esi
	set $si = $esi & 0xffff
	# from edi
	set $di = $edi & 0xffff
 end

end
document smallregisters
Create the 16 and 8 bit cpu registers (gdb doesn't have them by default)
And 32bits if we are dealing with 64bits binaries
end

define func
    if $argc == 0
        info functions
    end
    if $argc == 1
        info functions $arg0
    end
    if $argc > 1
        help func
    end
end
document func
Print all function names in target, or those matching REGEXP.
Usage: func <REGEXP>
end


define var
    if $argc == 0
        info variables
    end
    if $argc == 1
        info variables $arg0
    end
    if $argc > 1
        help var
    end
end
document var
Print all global and static variable names (symbols), or those matching REGEXP.
Usage: var <REGEXP>
end


define lib
    info sharedlibrary
end
document lib
Print shared libraries linked to target.
end


define sig
    if $argc == 0
        info signals
    end
    if $argc == 1
        info signals $arg0
    end
    if $argc > 1
        help sig
    end
end
document sig
Print what debugger does when program gets various signals.
Specify a SIGNAL as argument to print info on that signal only.
Usage: sig <SIGNAL>
end


define threads
    info threads
end
document threads
Print threads in target.
end


define dis
    if $argc == 0
        disassemble
    end
    if $argc == 1
        disassemble $arg0
    end
    if $argc == 2
      disassemble $arg0 $arg1
    end
    if $argc > 2
        help dis
    end
end
document dis
Disassemble a specified section of memory.
Default is to disassemble the function surrounding the PC (program counter)
of selected frame. With one argument, ADDR1, the function surrounding this
address is dumped. Two arguments are taken as a range of memory to dump.
Usage: dis <ADDR1> <ADDR2>
end




# __________hex/ascii dump an address_________
define ascii_char
    if $argc != 1
        help ascii_char
    else
        # thanks elaine :)
        set $_c = *(unsigned char *)($arg0)
        if ($_c < 0x20 || $_c > 0x7E)
            printf "."
        else
            printf "%c", $_c
        end
    end
end
document ascii_char
Print ASCII value of byte at address ADDR.
Print "." if the value is unprintable.
Usage: ascii_char ADDR
end


define hex_quad
    if $argc != 1
        help hex_quad
    else
        printf "%02X %02X %02X %02X %02X %02X %02X %02X", \
               *(unsigned char*)($arg0), *(unsigned char*)($arg0 + 1),     \
               *(unsigned char*)($arg0 + 2), *(unsigned char*)($arg0 + 3), \
               *(unsigned char*)($arg0 + 4), *(unsigned char*)($arg0 + 5), \
               *(unsigned char*)($arg0 + 6), *(unsigned char*)($arg0 + 7)
    end
end
document hex_quad
Print eight hexadecimal bytes starting at address ADDR.
Usage: hex_quad ADDR
end

define hexdump
    if $argc != 1
        help hexdump
    else
        echo \033[1m
        if ($64BITS == 1)
         printf "0x%016lX : ", $arg0
        else
         printf "0x%08X : ", $arg0
        end
        echo \033[0m
        hex_quad $arg0
        echo \033[1m
        printf " - "
        echo \033[0m
        hex_quad $arg0+8
        printf " "
        echo \033[1m
        ascii_char $arg0+0x0
        ascii_char $arg0+0x1
        ascii_char $arg0+0x2
        ascii_char $arg0+0x3
        ascii_char $arg0+0x4
        ascii_char $arg0+0x5
        ascii_char $arg0+0x6
        ascii_char $arg0+0x7
        ascii_char $arg0+0x8
        ascii_char $arg0+0x9
        ascii_char $arg0+0xA
        ascii_char $arg0+0xB
        ascii_char $arg0+0xC
        ascii_char $arg0+0xD
        ascii_char $arg0+0xE
        ascii_char $arg0+0xF
        echo \033[0m
        printf "\n"
    end
end
document hexdump
Display a 16-byte hex/ASCII dump of memory at address ADDR.
Usage: hexdump ADDR
end


# _______________data window__________________
define ddump
    if $argc != 1
        help ddump
    else
        echo \033[34m
        if ($64BITS == 1)
         printf "[0x%04X:0x%016lX]", $ds, $data_addr
        else
         printf "[0x%04X:0x%08X]", $ds, $data_addr
        end
	echo \033[34m
	printf "------------------------"
    printf "-------------------------------"
    if ($64BITS == 1)
     printf "-------------------------------------"
	end

	echo \033[1;34m
	printf "[data]\n"
        echo \033[0m
        set $_count = 0
        while ($_count < $arg0)
            set $_i = ($_count * 0x10)
            hexdump $data_addr+$_i
            set $_count++
        end
    end
end
document ddump
Display NUM lines of hexdump for address in $data_addr global variable.
Usage: ddump NUM
end


define dd
    if $argc != 1
        help dd
    else
        if ((($arg0 >> 0x18) == 0x40) || (($arg0 >> 0x18) == 0x08) || (($arg0 >> 0x18) == 0xBF))
            set $data_addr = $arg0
            ddump 0x10
        else
            printf "Invalid address: %08X\n", $arg0
        end
    end
end
document dd
Display 16 lines of a hex dump of address starting at ADDR.
Usage: dd ADDR
end


define datawin
 if ($64BITS == 1)
    if ((($rsi >> 0x18) == 0x40) || (($rsi >> 0x18) == 0x08) || (($rsi >> 0x18) == 0xBF))
        set $data_addr = $rsi
    else
        if ((($rdi >> 0x18) == 0x40) || (($rdi >> 0x18) == 0x08) || (($rdi >> 0x18) == 0xBF))
            set $data_addr = $rdi
        else
            if ((($rax >> 0x18) == 0x40) || (($rax >> 0x18) == 0x08) || (($rax >> 0x18) == 0xBF))
                set $data_addr = $rax
            else
                set $data_addr = $rsp
            end
        end
    end

 else
    if ((($esi >> 0x18) == 0x40) || (($esi >> 0x18) == 0x08) || (($esi >> 0x18) == 0xBF))
        set $data_addr = $esi
    else
        if ((($edi >> 0x18) == 0x40) || (($edi >> 0x18) == 0x08) || (($edi >> 0x18) == 0xBF))
            set $data_addr = $edi
        else
            if ((($eax >> 0x18) == 0x40) || (($eax >> 0x18) == 0x08) || (($eax >> 0x18) == 0xBF))
                set $data_addr = $eax
            else
                set $data_addr = $esp
            end
        end
    end
 end
    ddump $CONTEXTSIZE_DATA
end
document datawin
Display valid address from one register in data window.
Registers to choose are: esi, edi, eax, or esp.
end


# _______________process context______________
# initialize variable
set $displayobjectivec = 0

define context
    echo \033[34m
    if $SHOWCPUREGISTERS == 1
	    printf "----------------------------------------"
	    printf "----------------------------------"
	    if ($64BITS == 1)
	     printf "---------------------------------------------"
	    end
	    echo \033[34m\033[1m
	    printf "[regs]\n"
	    echo \033[0m
	    reg
	    echo \033[36m
    end
    if $SHOWSTACK == 1
	echo \033[34m
		if ($64BITS == 1)
		 printf "[0x%04X:0x%016lX]", $ss, $rsp
		else
    	 printf "[0x%04X:0x%08X]", $ss, $esp
    	end
        echo \033[34m
		printf "-------------------------"
    	printf "-----------------------------"
	    if ($64BITS == 1)
	     printf "-------------------------------------"
	    end
	echo \033[34m\033[1m
	printf "[stack]\n"
    	echo \033[0m
    	set $context_i = $CONTEXTSIZE_STACK
    	while ($context_i > 0)
       	 set $context_t = $sp + 0x10 * ($context_i - 1)
       	 hexdump $context_t
       	 set $context_i--
    	end
    end
# show the objective C message being passed to msgSend
   if $SHOWOBJECTIVEC == 1
#FIXME64
# What a piece of crap that's going on here :)
# detect if it's the correct opcode we are searching for
    	set $__byte1 = *(unsigned char *)$pc
    	set $__byte = *(int *)$pc
#
    	if ($__byte == 0x4244489)
      		set $objectivec = $eax
      		set $displayobjectivec = 1
    	end
#
    	if ($__byte == 0x4245489)
     		set $objectivec = $edx
     		set $displayobjectivec = 1
    	end
#
    	if ($__byte == 0x4244c89)
     		set $objectivec = $edx
     		set $displayobjectivec = 1
    	end
# and now display it or not (we have no interest in having the info displayed after the call)
    	if $__byte1 == 0xE8
     		if $displayobjectivec == 1
      			echo \033[34m
      			printf "--------------------------------------------------------------------"
  			    if ($64BITS == 1)
			     printf "---------------------------------------------"
	    		end
			echo \033[34m\033[1m
			printf "[ObjectiveC]\n"
      			echo \033[0m\033[30m
      			x/s $objectivec
     		end
     		set $displayobjectivec = 0
    	end
    	if $displayobjectivec == 1
      		echo \033[34m
      		printf "--------------------------------------------------------------------"
      		if ($64BITS == 1)
	     	 printf "---------------------------------------------"
	    	end
		echo \033[34m\033[1m
		printf "[ObjectiveC]\n"
      		echo \033[0m\033[30m
      		x/s $objectivec
    	end
   end
    echo \033[0m
# and this is the end of this little crap

    if $SHOWDATAWIN == 1
	 datawin
    end

    echo \033[34m
    printf "--------------------------------------------------------------------------"
    if ($64BITS == 1)
	 printf "---------------------------------------------"
	end
    echo \033[34m\033[1m
    printf "[code]\n"
    echo \033[0m
    set $context_i = $CONTEXTSIZE_CODE
    if($context_i > 0)
        x /i $pc
        set $context_i--
    end
    while ($context_i > 0)
        x /i
        set $context_i--
    end
    echo \033[34m
    printf "----------------------------------------"
    printf "----------------------------------------"
    if ($64BITS == 1)
     printf "---------------------------------------------\n"
	else
	 printf "\n"
	end

    echo \033[0m
end
document context
Print context window, i.e. regs, stack, ds:esi and disassemble cs:eip.
end


define context-on
    set $SHOW_CONTEXT = 1
    printf "Displaying of context is now ON\n"
end
document context-on
Enable display of context on every program break.
end


define context-off
    set $SHOW_CONTEXT = 0
    printf "Displaying of context is now OFF\n"
end
document context-off
Disable display of context on every program break.
end



# ____________________misc____________________
define hook-stop

    # this makes 'context' be called at every BP/step
    if ($SHOW_CONTEXT > 0)
        context
    end
end
document hook-stop
!!! FOR INTERNAL USE ONLY - DO NOT CALL !!!
end


define dump_hexfile
    dump ihex memory $arg0 $arg1 $arg2
end
document dump_hexfile
Write a range of memory to a file in Intel ihex (hexdump) format.
The range is specified by ADDR1 and ADDR2 addresses.
Usage: dump_hexfile FILENAME ADDR1 ADDR2
end


define dump_binfile
    dump memory $arg0 $arg1 $arg2
end
document dump_binfile
Write a range of memory to a binary file.
The range is specified by ADDR1 and ADDR2 addresses.
Usage: dump_binfile FILENAME ADDR1 ADDR2
end


define cls
    shell clear
end
document cls
Clear screen.
end

# bunch of semi-useless commands

# enable and disable shortcuts for stop-on-solib-events fantastic trick!
define enablesolib
	set stop-on-solib-events 1
end
document enablesolib
Shortcut to enable stop-on-solib-events trick!
end

define disablesolib
	set stop-on-solib-events 0
end
document disablesolib
Shortcut to disable stop-on-solib-events trick!
end

# enable commands for different displays
define enableobjectivec
	set $SHOWOBJECTIVEC = 1
end
document enableobjectivec
Enable display of objective-c information in the context window
end

define enablecpuregisters
	set $SHOWCPUREGISTERS = 1
end
document enablecpuregisters
Enable display of cpu registers in the context window
end

define enablestack
	set $SHOWSTACK = 1
end
document enablestack
Enable display of stack in the context window
end

define enabledatawin
	set $SHOWDATAWIN = 1
end
document enabledatawin
Enable display of data window in the context window
end

# disable commands for different displays
define disableobjectivec
	set $SHOWOBJECTIVEC = 0
end
document disableobjectivec
Disable display of objective-c information in the context window
end

define disablecpuregisters
	set $SHOWCPUREGISTERS = 0
end
document disablecpuregisters
Disable display of cpu registers in the context window
end

define disablestack
	set $SHOWSTACK = 0
end
document disablestack
Disable display of stack information in the context window
end

define disabledatawin
	set $SHOWDATAWIN = 0
end
document disabledatawin
Disable display of data window in the context window
end

define 32bits
	set $64BITS = 0
end
document 32bits
Set gdb to work with 32bits binaries
end

define 64bits
	set $64BITS = 1
end
document 64bits
Set gdb to work with 64bits binaries
end

define x86
	set $ARM = 0
end
document x86
Set gdb to work with x86 binaries
end

define arm
	set $ARM = 1
	set $64BITS = 0
end
document arm
Set gdb to work with ARM binaries
end

#EOF ^^


