#! /bin/sh

# create a makefile with the list of arguments as src
# the makefile create a rule named as the first argument
# minus his extension.

[ -f Makefile ] && echo 'A Makefile already exists' >&2 && exit 1
rule='main'
[ $# -gt 0 ] && rule=$(echo "$1" | cut -d '.' -f 1)

echo 'CPPFLAGS = -MMD' >> Makefile
echo 'CC ?= gcc' >> Makefile
echo 'CFLAGS ?= -Wall -Wextra -Werror -std=c99 -pedantic -g' >> Makefile
echo 'LDFLAGS =' >> Makefile
echo -e "LDLIBS =\n" >> Makefile
#echo "SRC =" >> Makefile
echo "SRC = $@" >> Makefile
echo 'DEP = ${SRC:.c=.d}' >> Makefile
#echo 'PRG = ${SRC:.c=}' >> Makefile
echo -e "OBJ = \${SRC:.c=.o}\n" >> Makefile
#echo 'all: ${PRG}' >> Makefile
echo -e "all: $rule\n" >> Makefile
echo -e "$rule: \${OBJ}\n" >> Makefile
echo -e ".PHONY: clean" >> Makefile
echo 'clean:' >> Makefile
#echo '	${RM} ${PRG}' >> Makefile
echo '	${RM} ${OBJ}' >> Makefile
echo '	${RM} ${DEP}' >> Makefile
echo '	${RM}'" $rule" >> Makefile
echo -e '	rm -f *.swp'"\n" >> Makefile
echo -e "-include \${DEP}" >> Makefile
#echo '	clear' >> Makefile
