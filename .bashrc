#
# ~/.bashrc
#

setxkbmap gb
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

export SHELL=/bin/sh
export TERMINAL=xterm

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
alias createMakefile='$HOME/Usefull/createMakefile.sh'
alias l='ls'
alias la='ls -a'
alias ll='ls -l'
alias sl='ls'
alias rider='/home/doth/Rider/JetBrains\ Rider-2017.3.1/bin/rider.sh'
alias idea='/home/doth/Intellij/idea-IU-181.4203.550/bin/idea.sh'
alias dcmake='cmake -DCMAKE_BUILD_TYPE=Debug'
alias ida32='wine ~/.wine/drive_c/Program\ Files\ \(x86\)/IDA\ 6.8/idaq.exe'
alias ida64='wine ~/.wine/drive_c/Program\ Files\ \(x86\)/IDA\ 6.8/idaq64.exe'
alias ropgadget='python /usr/src/ROPgadget/ROPgadget.py'
alias verilator='~/verilator/bin/verilator'
export PGDATA="$HOME/postgres_data"
