#ifndef REF_H
#define REF_H

#include <stdlib.h>

typedef void (*t_delete_handle)(void *);

struct            s_refcount
{
  size_t          count;
  t_delete_handle delete;
};

void refcount_init(struct s_refcount *ref, t_delete_handle del);

void refcount_decr(struct s_refcount *ref);

void refcount_incr(struct s_refcount *ref);

#endif
