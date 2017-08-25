#include "ref.h"

void refcount_init(struct s_refcount *ref, t_delete_handle del)
{
  ref->count = 1;
  ref->delete = del;
}

void refcount_decr(struct s_refcount *ref)
{
  ref->count -= 1;

  if (ref->count == 0)
    ref->delete(ref);
}

void refcount_incr(struct s_refcount *ref)
{
  ref->count += 1;
}
