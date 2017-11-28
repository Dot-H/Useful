#! /bin/sh

[  $# -eq 0 ] && exit 1


[ $1 == 'trash' ] || [ $1 == 'trash/' ] && ([ -f ~/trash ] || [ -d ~/trash ]) && rm -rf ~/trash && exit 0

[ ! -d ~/trash ] && mkdir ~/trash

tiret=0

for param; do
  [ ${param} == '--' ] && [ $tiret -eq 0 ] && tiret=1 && continue
  [ ${tiret} -eq 1 ] && tiret=0 && mv -- ${param} ~/trash && continue
  [ ${param:0:1} == '-' ] && continue
  [ ${param:0:1} == '*' ] && mv ${param} ~/trash
  if [ ! -e ~/trash/${param} ]; then
    mv ${param} ~/trash
  else
    time=$(echo $(date +"%T"))
    mv ${param} ${param}${time}
    mv ${param}${time} ~/trash
  fi
done
