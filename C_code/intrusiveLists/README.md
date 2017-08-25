Personal implementation of instrusive list.

The list use a reference counter (ref.h) to manage the memory and
has a sentinel. The delete function to the reference counter is
present in the intrusiveLists.h file as "list_delete_data)".

There are no function doing allocation and it's recommanded to use
the functions from the library to free the memory, do not forget
that the datas are manage by a reference counter. It could be a good
idea to make a create_data function like the one in the example.c file.

Every function from intrusiveLists.h (except list_init) must be called with
an initiated list.

Feel free to change the s_data_l structure. While there is a struct s_list list
and a struct s_refcount rcount the code should work just fine.
Nevertheless, the list_print function is made for the a specific data structure.
So if you change de s_data_l structure change the list_print function.

/* Alexandre BERNARD 2017-08-25 */
