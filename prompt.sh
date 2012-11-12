#!/bin/bash

txtblk='\[\033[0;30m\]' # Black - Regular
txtred='\[\033[0;31m\]' # Red
txtgrn='\[\033[0;32m\]' # Green
txtylw='\[\033[0;33m\]' # Yellow
txtblu='\[\033[0;34m\]' # Blue
txtpur='\[\033[0;35m\]' # Purple
txtcyn='\[\033[0;36m\]' # Cyan
txtwht='\[\033[0;37m\]' # White
bldblk='\[\033[1;30m\]' # Black - Bold
bldred='\[\033[1;31m\]' # Red
bldgrn='\[\033[1;32m\]' # Green
bldylw='\[\033[1;33m\]' # Yellow
bldblu='\[\033[1;34m\]' # Blue
bldpur='\[\033[1;35m\]' # Purple
bldcyn='\[\033[1;36m\]' # Cyan
bldwht='\[\033[1;37m\]' # White
unkblk='\[\033[4;30m\]' # Black - Underline
undred='\[\033[4;31m\]' # Red
undgrn='\[\033[4;32m\]' # Green
undylw='\[\033[4;33m\]' # Yellow
undblu='\[\033[4;34m\]' # Blue
undpur='\[\033[4;35m\]' # Purple
undcyn='\[\033[4;36m\]' # Cyan
undwht='\[\033[4;37m\]' # White
bakblk='\[\033[40m\]'   # Black - Background
bakred='\[\033[41m\]'   # Red
badgrn='\[\033[42m\]'   # Green
bakylw='\[\033[43m\]'   # Yellow
bakblu='\[\033[44m\]'   # Blue
bakpur='\[\033[45m\]'   # Purple
bakcyn='\[\033[46m\]'   # Cyan
bakwht='\[\033[47m\]'   # White
txtrst='\[\033[0m\]'    # Text Reset


# Set some default colors
uidColor=$bldred
punctColor=$bldblu
textColor=$bldwht
gitColor=$bldylw

# change colors per-host 
case `hostname` in
    engels)
        textColor=$txtwht
        punctColor=$txtred
        ;;

    vera)
        #textColor='\[\033[$(let "i=($RANDOM % 7) + 30"; echo $i)m\]'
        punctColor=$bldpur
        textColor=$bldwht
        gitColor=$txtpur
        ;;
    
    wenshu)
        #textColor='\[\033[$(let "i=($RANDOM % 7) + 30"; echo $i)m\]'
        punctColor=$bldblk
        textColor=$txtgrn
        gitColor=$txtgrn
        ;;

    guanyin)
        #textColor='\[\033[$(let "i=($RANDOM % 7) + 30"; echo $i)m\]'
        punctColor=$txtcyn
        textColor=$bldblu
        gitColor=$txtpur
        ;;

    *)
        ;;
esac

## If the user is root, set the uid color to a special value
if [ "`/usr/bin/whoami`" == "root" ]
then
    uidColor=$bakwht$bldred
fi

# Get the name of the branch we are on
function git_prompt_info() {
  ICON_COLOR='\[\033[0;33m\]'
  GIT_COLOR='\[\033[0;33m\]'
  branch_prompt=$(__git_ps1)
  if [ -n "$branch_prompt" ]; then
    echo $branch_prompt$status_icon
  fi
}

function trimmed_path {
    local MAX_PATH=30
    # convert $HOME to '~'
    HPWD=${PWD/#$HOME/\~}
    # take the last xx chars of current directory
    TRIMMED_PWD=${HPWD: -$MAX_PATH};
    # if less than xx chars, use the whole current directory
    TRIMMED_PWD=${TRIMMED_PWD:-$HPWD}
    # now see if we had to cut:
    if [ "$HPWD" == "$TRIMMED_PWD" ]; then
        echo $HPWD
    else
        # remove truncated dir name (if there) at beginning of string
        # and the initial '/' to make it clear pwd shown is not
        # off filesys root
        # e.g. `pwd`     --> /some/long/dir/that/is/very/long/
        # TRIMMED_PWD    --> ir/that/is/very/long
        # TRIMMED_PWD#*/ --> that/is/ver/long
        #echo ${TRIMMED_PWD#*/}
        # UPDATE: add elipsis and slash
        echo "…/${TRIMMED_PWD#*/}"
    fi
}

# WIP - probably not useful
function term_info {
    echo "$WINDOW"

}

function makePrompt {

    local UID_COLOR=$uidColor
    local PUNCT=$punctColor
    local TEXT=$textColor
    local NO_COLOR=$txtrst
    local GIT_COLOR=$gitColor
    
    
    case $TERM in
        xterm*|rxvt*)
            TITLEBAR='\[\033]0;\u@\h:\w\007\]'
            ;;
        *)
            TITLEBAR=""
            ;;
    esac
    
    export PS1="$TITLEBAR\
$TEXT-$PUNCT-(\
$TEXT\$(date +%0H\:%0M)$PUNCT-$TEXT\$(date \"+%d%b%y\")\
$PUNCT)-(\
$TEXT$(term_info)$PUNCT/$TEXT\!$PUNCT)-(\
$TEXT\$(trimmed_path)\
$PUNCT)-$TEXT- $GIT_COLOR\$(git_prompt_info)\
\n\
$TEXT-$PUNCT-(\
$TEXT\u$PUNCT@$TEXT\h\
$PUNCT:$UID_COLOR\$$PUNCT)-$TEXT- $NO_COLOR"

#export PS2="$PUNCT-$TEXT-$PUNCT- $NO_COLOR"

}

makePrompt
export GIT_PS1_SHOWDIRTYSTATE=true

unset makePrompt
