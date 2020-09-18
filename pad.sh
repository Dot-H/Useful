#!/bin/bash

touchpad_device=$(xinput | grep 'TouchPad' | cut -d'=' -f2 | cut -d$'\t' -f1)

usage() {
    echo "Usage: $0 <up|down>" >&2 && exit 1
}

padup() {
    xinput enable $touchpad_device
}

paddown() {
    xinput disable $touchpad_device
}

[ $# -ne 1 ] && usage

case $1 in
"up") padup ;;
"down") paddown ;;
*) usage ;;
esac

