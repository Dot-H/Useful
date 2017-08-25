CC=gcc
CFLAGS=-Wall -Wextra -Werror -pedantic -std=c99 -g3

LIST_SRC = ref.c intrusiveLists.c example.c
.PHONY: hash clean

list:
	$(CC) $(CFLAGS) $(LIST_SRC) -o list -g

clean:
	$(RM) list
