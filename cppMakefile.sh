#!/bin/sh

# create a makefile with the list of arguments as src
# the makefile create a rule named as the first argument
# minus his extension.

[ -f Makefile ] && echo 'A Makefile already exists' >&2 && exit 1

rule='main'
[ $# -gt 0 ] && rule=$(echo "$1" | cut -d '.' -f 1)

for arg in "$@"; do
  if [ ! -f $arg ]; then
    echo "$arg does not exits or is not a file" >&2
    exit 1
  fi
done

echo 'CXX = g++' >> Makefile
echo 'CC = g++' >> Makefile
echo 'CPPFLAGS += -Wall -Wextra -std=c++17 -pedantic' >> Makefile
echo 'LDFLAGS =' >> Makefile
echo -e "LDLIBS =\n" >> Makefile

# Put the arguments in the source
echo "SRC = $@" >> Makefile
echo -e "OBJS = \${SRC:.cpp=.o}\n" >> Makefile

#add the first .c as executable name and default rule
echo -e "all: $rule\n" >> Makefile
echo -e "$rule: \${OBJS}\n" >> Makefile

# creates a rule check to make the check and aplly the gdb flag
echo -e "check: CPPFLAGS += -g3 -DTEST" >> Makefile
echo -e "check: $rule\n" >> Makefile

echo -e ".PHONY: clean check" >> Makefile
echo 'clean:' >> Makefile
echo '	${RM} ${OBJS}' >> Makefile
echo '	${RM}'" $rule" >> Makefile
