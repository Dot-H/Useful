#! /bin/sh

[  $# -eq 0 ] && exit 1


[ $1 == 'trash' ] || [ $1 == 'trash/' ] && ([ -f ~/trash ] || [ -d ~/trash ]) && rm -rf ~/trash && exit 0

[ ! -d ~/trash ] && mkdir ~/trash

tiret=0

for param; do
  [ $param == '--' ] && [ $tiret -eq 0 ] && tiret=1 && continue
  [ $tiret -eq 1 ] && tiret=0 && mv -- $param ~/trash && continue
  [ ${param:0:1} == '-' ] && continue
  [ $param == '*' ] && mv * ~/trash
  if [ ! -f ~/trash/$param ] && [ ! -d ~/trash/$param ]; then
    mv $param ~/trash
  else
    var=$(shuf -i 0-9999999 -n 1)
    mv $param $param$var
    mv $param$var ~/trash
  fi
done
