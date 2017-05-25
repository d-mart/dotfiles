# bash builtins, general shell aliases, etc

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
# ... or force ignoredups and ignorespace
export HISTCONTROL=ignoreboth
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)

# CDPATH - like PATH but for CD command.  When
# typing 'cd mydir' look in all these directories,
# not just pwd
#export CDPATH='~/proj:~/.emacs.d'

# HISTIGNORE - keep uninteresting (or sensitive)
# commands out of bash history
export HISTIGNORE="[bf]g:exit:ls:pwd:top:w:history"     #"[bf]g:exit:ls:ls *:cd *:top:w"

# append to the history file, don't overwrite it
shopt -s histappend

# correct minor misspellings (transpositions etc) in CD commands
shopt -s cdspell

# extended glob
#This will give you ksh-88 egrep-style extended pattern matching or, in other words, turbo-charged pattern matching within bash. The available operators are:
#    ?(pattern-list)
#Matches zero or one occurrence of the given patterns
#    *(pattern-list)
#Matches zero or more occurrences of the given patterns
#    +(pattern-list)
#Matches one or more occurrences of the given patterns
#    @(pattern-list)
#Matches exactly one of the given patterns
#    !(pattern-list)
#Matches anything except one of the given patterns
#Here's an example. Say, you wanted to install all RPMs in a given directory, except those built for the noarch architecture. You might use something like this:
#    rpm -Uvh /usr/src/RPMS/!(*noarch*)
#These expressions can be nested, too, so if you wanted a directory listing of all non PDF and PostScript files in the current directory, you might do this:
#    ls -lad !(*.p@(df|s))
shopt -s extglob

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# automatically cd into a directory if the command entered doesn't exists
shopt -s autocd

# got this from running 'dircolors' on a ubuntu system
LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:';
export LS_COLORS
export CLICOLOR=true

if [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
fi

#####
# Proceed with general initialization
#####
source "${SHELL_HOME}/shell-init.sh"

if [ "$OS" = "mac" ]; then
    source `/usr/local/bin/brew --prefix`/etc/bash_completion.d/git-prompt.sh
    source `/usr/local/bin/brew --prefix`/etc/bash_completion.d/git-completion.bash
fi

if [ -x $(which direnv) ]; then
  eval "$(direnv hook bash)"
fi

source "${SHELL_HOME}/bash-prompt.sh"
