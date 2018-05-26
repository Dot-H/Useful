#!/bin/sh

dims=$(xrandr | grep -o '[0-9]\+x[0-9]\++[0-9]\++[0-9]\+')
echo "$dims"
for dim in $dims; do
xwinwrap -g $dim -ov -ni -s -nf -- mplayer -fs -wid WID -quiet -loop 0 $1& 2>&1 > /dev/null
done
