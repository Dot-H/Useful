#! /bin/sh

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

clear

[ ! -f *.o ] && echo ".o: ${GREEN}OK${NC}" || echo ".o: ${RED}KO${NC}"

[ ! -f *.d ] && echo ".d: ${GREEN}OK${NC}" || echo ".d: ${RED}KO${NC}"

[ ! -f *.swp ] && echo ".swp: ${GREEN}OK${NC}" || echo ".swp: ${RED}KO${NC}"

if [ -f "AUTHORS" ]; then
  length=$(wc -m < AUTHORS)
  line=$(wc -l <AUTHORS)
  if [ ${length} -gt 4 ] && [ $line -eq 1 ]; then
    echo "AUTHORS: ${GREEN}OK${NC}"
  else
    echo "AUTHORS: ${RED}KO${NC}"
  fi
else
  echo "AUTHORS: ${RED}KO${NC}"
fi
