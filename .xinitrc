#! /bin/sh

[[ -f ~/.Xresources ]] && xrdb -merge .Xresources
[[ -f ~/.screenlayout/dual.sh ]] && . ~/.screenlayout/dual.sh

exec i3
