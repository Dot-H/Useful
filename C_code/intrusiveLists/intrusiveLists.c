#include "intrusiveLists.h"
#include <stdio.h>
#include <assert.h>

#define CONTAINER_OF(Typename, Fieldname, Ptr)                  \
  ((Typename*)(((char*)Ptr - offsetof(Typename, Fieldname))))

void list_init(struct s_list *sentinel)
{
  assert(sentinel);

  sentinel->next = NULL;
}

int list_is_empty(struct s_list *l)
{
  return l->next == NULL;
}

void list_push_front(struct s_list *l, struct s_list *cell)
{
  cell->next = l->next;
  l->next = cell;
}

void list_push_back(struct s_list *l, struct s_list *cell)
{
  while (l->next)
    l = l->next;

  l->next = cell;
}

int       list_insert_at(struct s_list *l, struct s_list *cell, size_t i)
{
  size_t  cpt = 0;

  while (l->next && cpt < i)
  {
    l = l->next;
    ++cpt;
  }

  if (cpt < i) // Invalid index
    return -1;


  cell->next = l->next;
  l->next = cell;
  return 0;
}

struct s_list   *list_pop_front(struct s_list *l)
{
  struct s_list *cell = l->next;

  if (cell)
  {
    l->next = cell->next;
    cell->next = NULL;
  }
  return cell;
}

size_t            list_len(struct s_list *l)
{
  size_t          len = 0;
  struct s_list   *cur;

  for (cur = l; cur->next; cur = cur->next)
    len++;

  return len;
}

struct s_data_l *list_get_data(struct s_list *cell)
{
  return CONTAINER_OF(struct s_data_l, list, cell);
}

void list_delete_data(void *cell)
{
  free(CONTAINER_OF(struct s_data_l, rcount, cell));
}

void list_print(struct s_list *l)
{
  for (; l->next; l = l->next)
  {
    struct s_data_l *d = CONTAINER_OF(struct s_data_l, list, l->next);
    printf("%s %s -> ", d->firstname, d->lastname);
  }
}

void list_delete(struct s_list *l)
{
  while (!list_is_empty(l))
  {
    struct s_data_l *d = CONTAINER_OF(struct s_data_l, list, list_pop_front(l));
    refcount_decr(&d->rcount);
  }

  free(l);
}

struct    s_data_l *list_elt_at(struct s_list *l, size_t i)
{
  size_t  x = 0;
  for (; x < i && l->next; ++x, l = l->next)
    ;

  return l->next ? list_get_data(l->next) : NULL;
}

struct s_list   *list_pop_at(struct s_list *l, size_t i)
{
  size_t        x = 0;
  struct s_list *res;

  for (; x < i && l->next; ++x, l = l->next)
    ;

  if (!l)
    return NULL;

  res = l->next;
  l->next = res->next;
  res->next = NULL;

  return res;
}

struct s_list *list_find(struct s_list *l, int (*predicate) (struct s_data_l *))
{
  for (; l->next && !predicate(list_get_data(l->next)); l = l->next)
    ;

  return l->next;
}
