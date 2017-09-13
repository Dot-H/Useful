CPPFLAGS = -MMD
CC ?= gcc
CFLAGS = -Wall -Wextra -Werror -std=c99 -pedantic -g
LDFLAGS =
LDLIBS =

SRC = test.c
DEP = ${SRC:.c=.d}
OBJ = ${SRC:.c=.o}

all: test

test: ${OBJ}

.PHONY: clean
clean:
	${RM} ${OBJ}
	${RM} ${DEP}
	${RM} test
	rm -f *.swp

-include ${DEP}
