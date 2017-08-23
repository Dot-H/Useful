Generic hash table library using djb2 hash function.

===== HOW TO USE =====
  * In hash_table.h:
    * Setup the TYPE_VALUE macro with key's value type
    * Setup the PRINT_FORMAT and CAST_FORMAT macros if you want to use the
      print_htable function
  * In your code:
    * create the table using the create_table function
    * add key, value using add_htable function
    * do whatever you need to do
    * free the table using clear_table function

*Alexandre BERNARD 2017-08-23*
