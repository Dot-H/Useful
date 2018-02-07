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

PTH="\[$(tput setaf 214)\]"
USR="\[$(tput setaf 46)\]"
RST="\[$(tput sgr0)\]"

PS1="${USR}\u@\h ${PTH}\w ${RST}\$ "

alias gdb='gdb -q'
alias createMakefile='$HOME/Usefull/createMakefile.sh'
alias l='ls'
alias la='ls -a'
alias ll='ls -l'
alias sl='ls'
alias rider='/usr/bin/Rider-2017.2/bin/rider.sh'
alias dcmake='cmake -DCMAKE_BUILD_TYPE=Debug'
alias headers='ofiles "*.h"'
alias srcs='ofiles "*.c"'
alias ida32='wine ~/.wine/drive_c/Program\ Files/IDA\ 7.0/ida.exe'
alias ida64='wine ~/.wine/drive_c/Program\ Files/IDA\ 7.0/ida64.exe'
alias ropgadget='python /usr/src/ROPgadget/ROPgadget.py'
alias verilator='~/verilator/bin/verilator'
