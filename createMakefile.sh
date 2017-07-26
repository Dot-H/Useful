#! /bin/sh

touch Makefile
echo 'CC=gcc' >> Makefile
echo 'CPPFLAGS= -MMD' >> Makefile
echo 'CFLAGS= -Wall -Wextra -Werror -std=c99 -pedantic -g' >> Makefile
echo 'LDFLAGS=' >> Makefile
echo 'LDLIBS=' >> Makefile
echo '' >> Makefile
echo 'SRC=' >> Makefile
echo 'DEP= ${SRC:.c=.d}' >> Makefile
echo 'PRG= ${SRC:.c=}' >> Makefile
echo '' >> Makefile
echo 'all: ${PRG}' >> Makefile
echo '' >> Makefile
echo '-include ${DEP}' >> Makefile
echo '' >> Makefile
echo 'clean:' >> Makefile
echo '  rm -f *.o' >> Makefile
echo '  rm -f *.d' >> Makefile
echo '  rm -f ${PRG}' >> Makefile
echo '  rm -f *.swp' >> Makefile
echo '  clear' >> Makefile
