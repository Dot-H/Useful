#include "intrusiveLists.h"
#include <stdio.h>
#include <string.h>

static inline
struct s_data_l *create_data(char *firstname, char *lastname, unsigned uid)
{
  struct s_data_l *data = calloc(4, sizeof (struct s_data_l));
  data->firstname = firstname;
  data->lastname = lastname;
  data->uid = uid;
  refcount_init(&data->rcount, list_delete_data);

  return data;
}

static inline
int find_by_firstname(struct s_data_l *d)
{
  return (strcmp(d->firstname, "tot8") == 0);
}

int main()
{
  // The sentinel is the head of the list and has no data associated.
  // Those three lines are code are essential.
  struct s_list *sentinel;
  sentinel = malloc(sizeof (struct s_list));
  list_init(sentinel);

  printf("====== PUSHING TEST =======\n\n");

  // Different ways to add the data
  struct s_data_l *data = create_data("toto", "tota", 0);
  list_push_front(sentinel, &data->list);
  struct s_data_l *data1 = create_data("tot1", "tota", 1);
  list_push_front(sentinel, &data1->list);
  struct s_data_l *data2 = create_data("tot2", "tota", 2);
  list_push_front(sentinel, &data2->list);
  struct s_data_l *data3 = create_data("tot3", "tota", 3);
  list_push_front(sentinel, &data3->list);
  struct s_data_l *data4 = create_data("tot4", "tota", 4);
  list_push_front(sentinel, &data4->list);
  struct s_data_l *data5 = create_data("tot5", "tota", 5);
  list_push_front(sentinel, &data5->list);
  struct s_data_l *data6 = create_data("tot6", "tota", 6);
  list_push_front(sentinel, &data6->list);
  struct s_data_l *data7 = create_data("tot7", "tota", 7);
  list_push_front(sentinel, &data7->list);
  struct s_data_l *data8 = create_data("tot8", "tota", 8);
  list_push_front(sentinel, &data8->list);
  struct s_data_l *data9 = create_data("tot9", "tota", 9);
  list_push_front(sentinel, &data9->list);
  struct s_data_l *data0 = create_data("tot0", "tota", 10);
  list_push_front(sentinel, &data0->list);

  struct s_data_l *data11 = create_data("tot11", "totq", 11);
  list_push_back(sentinel, &data11->list);

  struct s_data_l *data13 = create_data("insertAt0", "tota", 13);
  list_insert_at(sentinel, &data13->list, 0);
  struct s_data_l *data12 = create_data("insertAt4", "tota", 12);
  list_insert_at(sentinel, &data12->list, 4);
  struct s_data_l *data14 = create_data("insertAt14", "tota", 14);
  list_insert_at(sentinel, &data14->list, 14);
  struct s_data_l *data15 = create_data("insertAt100", "tota", 100);
  if (list_insert_at(sentinel, &data15->list, 100) == -1)
  {
    printf("\ninsertAt100 did not insert.\n");
    refcount_decr(&data15->rcount);
  }

  list_print(sentinel);

  printf("\n\n====== REMOVING AND REFCOUNT TEST ======\n\n");
  // Different ways to remove datas from the list. Think that the data is not
  // free. So you should decrease the refcount when the variable is not needed
  // anymore

  struct s_data_l *toto = list_get_data(list_pop_front(sentinel));
  printf("\npop front: %s %s", toto->firstname, toto->lastname);
  refcount_decr(&toto->rcount);

  toto = list_get_data(list_pop_at(sentinel, 4));
  printf("\npop at 4: %s %s\n\n", toto->firstname, toto->lastname);
  refcount_decr(&toto->rcount);

  list_print(sentinel);

  printf("\n\n====== FINDING TEST ======\n\n");
  // Differnet ways to get the data from the list without removing it.

  toto = list_elt_at(sentinel, 6);
  printf("\nelt at 6: %s %s", toto->firstname, toto->lastname);
  refcount_decr(&toto->rcount);

  toto = list_get_data(list_find(sentinel, find_by_firstname));
  printf("\nelt like firstname = \"tot8\": %s %s %u\n\n", toto->firstname,
         toto->lastname, toto->uid);
  refcount_decr(&toto->rcount);

  list_print(sentinel);

  printf("\n\n====== END ====== \n");

  // Destroy the list. But carefull, it only decrease the refcount. So if you
  // have store the data somewhere else, it won't be free.
  list_delete(sentinel);

  return 0;
}
