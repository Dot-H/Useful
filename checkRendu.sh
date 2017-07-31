#! /bin/sh

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

clear
array_o=`find . -name "*.o"`
array_d=`find . -name "*.d"`
array_swp=`find . -name ".*.swp"`

[ ${#array_o[@]} -gt 0 ] && echo ".o: ${RED}KO${NC}" || echo ".o: ${GREEN}OK${NC}"

[ ${#array_d[@]} -gt 0 ] && echo ".d: ${RED}KO${NC}" || echo ".d: ${GREEN}OK${NC}"

[ ${#array_swp[@]} -gt 0 ] && echo ".swp: ${RED}KO${NC}" || echo ".swp: ${GREEN}OK${NC}"

[ -f "TODO" ] && echo "TODO: ${GREEN}OK${NC}" || echo "TODO: ${RED}KO${NC}"

[ -f "README" ] && echo "README: ${GREEN}OK${NC}" || echo "README: ${RED}KO${NC}"

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
