#ifndef INTRUSIVELISTS_H
#define INTRUSIVELISTS_H

#include <stdlib.h>
#include <stddef.h>
#include "ref.h"

struct          s_list
{
  struct s_list   *next;
};

struct              s_data_l
{
  char              *firstname;
  char              *lastname;
  unsigned          uid;
  struct s_list     list;
  struct s_refcount   rcount;
};


/*
** list_init(sentinel)
** Initialize list sentinel
*/
void list_init(struct s_list *sentinel);

/*
** list_is_empty(l)
** test for empty list (doesn't work for uninitialized list)
*/
int list_is_empty(struct s_list *l);

/*
** list_push_front(l, cell)
** add cell in front of the list
** (keep sentinel unchanged)
*/
void list_push_front(struct s_list *l, struct s_list *cell);

/*
** list_push_back(l, cell)
** add cell in back of the list
*/
void list_push_back(struct s_list *l, struct s_list *cell);

/*
** list_insert_at(l, cell, i)
** insert cell at the index i
** return 0 if success and -1 if index not valid
*/
int list_insert_at(struct s_list *l, struct s_list *cell, size_t i);

/*
** list_pop_front(l)
** extract and return the first element of the list
** returns null if the list is empty
** (keep sentinel unchanged)
*/
struct s_list *list_pop_front(struct s_list *l);

/*
** list_len(l)
** return the len of the list
** do not count the sentinel
*/
size_t list_len(struct s_list *l);

/*
** list_get_data(cell)
** return the data corresponding to the cell given as argument
*/
struct s_data_l *list_get_data(struct s_list *cell);

/*
** list_delete_data(cell)
** delete handling function when refcount reach zero
** free the data coresponding to the cell
*/
void list_delete_data(void *cell);

/*
** list_print(l)
** print the list as firstname lastname -> ....
*/
void list_print(struct s_list *l);

/*
** list_delete(l)
** delete the entire list
*/
void list_delete(struct s_list *l);

/*
** list_elt_at(l, i)
** get the elt at the index i
** return null if not found
** /!\ Care, the refcount is incremented
*/
struct s_data_l *list_elt_at(struct s_list *l, size_t i);

/*
** list_pop_at(l, i)
** remove the cell at the index i from the list and return it
** return null if not found
*/
struct s_list *list_pop_at(struct s_list *l, size_t i);

/*
** list_find(l, predicat)
** return the first occurence of the data verifying the predicate
** the predicate must return 0 if false and a positive value otherwise
** return null if not found
** /!\ Care, the refcount is incremented
*/
struct s_list *list_find(struct s_list *l, int (*predicate)(struct s_data_l *));

#endif
