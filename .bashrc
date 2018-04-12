#
# ~/.bashrc
#

function ofiles () {
    [ $# -ne 2 ] && echo "Usage: ofiles PATTERN" 1&>2 && exit 1
    files=$(find -name "$1")
    open=""
    for file in $files; do
        [ -f $file ] && open="${open} $file"
    done
    [ $open = "" ] && echo "no headers" 1&>2 && exit 1
    vim -p $open
}

setxkbmap gb
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'

export SHELL=/bin/sh
export TERMINAL=xterm
export EDITOR=vim

PTH="\[$(tput setaf 214)\]"
USR="\[$(tput setaf 46)\]"
RST="\[$(tput sgr0)\]"

PS1="${USR}\u@\h ${PTH}\w ${RST}\$ "

function termsize() {
    [ $# -eq 0 ] && echo "termsize SIZE" && return 1

    # defaults
    printf '\33]50;%s\007' "xft:Hack:antialias=true:hinting=true:pixelsize=$1"
    printf '\033]711;%s\007' "xft:Hack:bold:antialias=true:hinting=true:pixelsize=$1"
    printf '\033]712;%s\007' "xft:Hack:bold:antialias=true:hinting=true:pixelsize=$1"
    printf '\033]713;%s\007' "xft:Hack:bold:antialias=true:hinting=true:pixelsize=$1"
}


alias gdb='gdb -q'
alias cMakefile='$HOME/Usefull/cMakefile.sh'
alias cppMakefile='$HOME/Usefull/cppMakefile.sh'
alias l='ls'
alias la='ls -a'
alias ll='ls -l'
alias sl='ls'
alias rider='/usr/bin/Rider-2017.2/bin/rider.sh'
alias idea='/usr/bin/idea-IU-181.4203.550/bin/idea.sh'
alias dcmake='cmake -DCMAKE_BUILD_TYPE=Debug'
alias headers='ofiles "*.h"'
alias srcs='ofiles "*.c"'
alias ida32='wine ~/.wine/drive_c/Program\ Files/IDA\ 7.0/ida.exe'
alias ida64='wine ~/.wine/drive_c/Program\ Files/IDA\ 7.0/ida64.exe'
alias ropgadget='python /usr/src/ROPgadget/ROPgadget.py'
alias verilator='~/verilator/bin/verilator'
export PGDATA="$HOME/postgres_data"
