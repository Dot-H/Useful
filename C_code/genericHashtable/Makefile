CC=gcc
CFLAGS=-Wall -Wextra -Werror -pedantic -std=c99 -g3

HASH_SRC = hashtable.c
.PHONY: hash clean

hash:
	$(CC) $(CFLAGS) $(HASH_SRC) -o hash -g

clean:
	$(RM) hash
