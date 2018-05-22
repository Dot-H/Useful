#
# ~/.zshrc
#

# Ok it should not be here soz
setxkbmap gb

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Environment variables
export PS1="%F{076}%n@%m %F{166}%~ %f\$ "
export LANG=en_GB.UTF-8
export EDITOR=vim
export PGDATA="$HOME/postgres_data"

# Double tab customization
autoload -Uz compinit
compinit
setopt COMPLETE_ALIASES
zstyle ':completion:*' menu select

# Font size setter
termsize() {
    [ $# -eq 0 ] && echo "termsize SIZE" && return 1

    # defaults
    printf '\33]50;%s\007' "xft:Hack:antialias=true:hinting=true:pixelsize=$1"
    printf '\033]711;%s\007' "xft:Hack:bold:antialias=true:hinting=true:pixelsize=$1"
    printf '\033]712;%s\007' "xft:Hack:bold:antialias=true:hinting=true:pixelsize=$1"
    printf '\033]713;%s\007' "xft:Hack:bold:antialias=true:hinting=true:pixelsize=$1"
}

# Listing with colors
alias tree='tree -C'
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Forbid rm command
alias del='trash-put'
alias rm="1>&2 echo 'plz use del in order to have use the trashcli interface'"

# Silence gdb
alias gdb='gdb -q'

# Typos solver
alias l='ls'
alias la='ls -a'
alias ll='ls -l'
alias sl='ls'

# From source commands
alias rider='/home/doth/Rider/bin/rider.sh'
alias idea='/home/doth/Intellij/idea-IU-181.4203.550/bin/idea.sh'
alias dcmake='cmake -DCMAKE_BUILD_TYPE=Debug'
alias ida32='wine ~/.wine/drive_c/Program\ Files\ \(x86\)/IDA\ 6.8/idaq.exe'
alias ida64='wine ~/.wine/drive_c/Program\ Files\ \(x86\)/IDA\ 6.8/idaq64.exe'
alias ropgadget='python /usr/src/ROPgadget/ROPgadget.py'
alias verilator='~/verilator/bin/verilator'

# Custom commands
alias cMakefile='$HOME/Usefull/cMakefile.sh'
alias cppMakefile='$HOME/Usefull/cppMakefile.sh'
