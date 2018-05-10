export SHELL=/bin/zsh
export TERMINAL=urxvt
export LANG=C

[[ -f ~/.zshrc ]] && . ~/.zshrc
if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
    exec startx
fi
