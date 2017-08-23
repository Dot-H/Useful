/* hash_table.h */
/* Hash Table implementation: header */

# ifndef _HASHTABLE_H_
# define _HASHTABLE_H_

# include <stdint.h>
# include <stdlib.h>

/* Has to be smth like:
 *   returnType (*value) (arg1, arg2 ...)
 *   OR
 *   void *value
     OR
 *   type value
 */
# define TYPE_VALUE int (*value) (int, int)
# define PRINT_FORMAT "%p"
# define CAST_FORMAT (void *)&
# define MAX_THRESHOLD 0.75

struct pair {
  uint32_t              hkey;
  char                 *key;
  TYPE_VALUE;
  struct pair          *next;
};

struct htable {
  size_t                size, capacity;
  struct pair         **tab;
};

/*
 * hash(data):
 * compute the hash of the nul terminated string data.
 */
uint32_t hash(char *data);

/*
 * create_htable(capacity):
 * build a new hash table with initial capacity.
 */
struct htable *create_htable(size_t capacity);

/*
 * access_htable(htable, key):
 * returns a pointer to the pair containing the given key
 */
struct pair *access_htable(struct htable *htable, char *key);

/*
 * add_htable(htable,key,value):
 * add the pair (key,value) to the hash table
 */
int add_htable(struct htable *htable, char *key, TYPE_VALUE);

/*
 * remove_htable(htable, key):
 * removes the pair containing the given key from the hash table
 */
void remove_htable(struct htable *htable, char *key);

/*
 * clear_htable(htable):
 * delete all pairs in the table. Doesn't free both the value and the key;
 */
void clear_htable(struct htable *htable);

/*
 * print_htable(htable):
 * print the htable
 */
void print_htable(struct htable *htable);

/*
 * test_htable()
 * some printable test of every function of the library
 */
void test_htable(void);

/*
 * resize_htable():
 * reconstruct the table when capacity / size > MAX_THRESHOLD
 */
void resize_htable(struct htable *old);

# endif /* _HASHTABLE_H_ */
