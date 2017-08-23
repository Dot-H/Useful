#include "hashtable.h"
#include "string.h"
#include <stdio.h>

int addition(int a, int b) {
  return a + b;
}

int multiplication(int a, int b) {
  return a * b;
}

uint32_t hash(char *data) {
    uint32_t hash = 5381;
    int c;

    while ((c = *data++))
        hash = ((hash << 5) + hash) + c;

    return hash;
}

struct htable *create_htable(size_t capacity) {
  struct htable *table = malloc(sizeof(struct htable));

  table->size = 0;
  table->capacity = capacity;
  table->tab = calloc(capacity, sizeof(struct pair));

  return table;
}

struct pair *access_htable (struct htable *htable, char *key) {
  uint32_t h = hash(key);
  size_t i = h % htable->capacity;
  struct pair *p = htable->tab[i];

  while(p) {
    if (strcmp(p->key, key) == 0)
        return p;

    p = p->next;
  }

  return NULL;
}

int add_htable(struct htable *htable, char *key, TYPE_VALUE) {
  uint32_t h = hash(key);
  size_t i = h % htable->capacity;
  struct pair *p = htable->tab[i];

  while (p) {
    if (strcmp(p->key, key) == 0)
      return 0;

    p = p->next;
  }

  p = htable->tab[i];
  htable->tab[i] = malloc(sizeof(struct pair));
  htable->tab[i]->hkey = h;
  htable->tab[i]->key = key;
  htable->tab[i]->value = value;
  htable->tab[i]->next = p;
  htable->size++;

  if (htable->size / htable->capacity > MAX_THRESHOLD)
    resize_htable(htable);

  return 1;
}

void print_htable(struct htable *htable) {
  printf("Size: %zu\n", htable->size);

  for (size_t i = 0; i < htable->capacity; ++i)
  {
    if (!htable->tab[i])
      continue;

    struct pair *p = htable->tab[i];
    printf("%s : "PRINT_FORMAT"\n", p->key, CAST_FORMAT p->value);
    p = p->next;

    while (p)
    {
      printf(". %s : "PRINT_FORMAT"\n", p->key, CAST_FORMAT p->value);
      p = p->next;
    }
  }
}

void remove_htable(struct htable *htable, char *key) {
  uint32_t h = hash(key);
  size_t i = h % htable->capacity;
  struct pair *p = htable->tab[i];
  struct pair *prev = NULL;

  while(p && strcmp(p->key, key) != 0) {
    prev = p;
    p = p->next;
  }

  if (!p)
    return;

  if (prev)
    prev->next = p->next;
  else
     htable->tab[i] = p->next;

  free(p);
  htable->size -= 1;
}

void clear_htable(struct htable *htable) {
  struct pair *p, *tmp;

  for (size_t i = 0; i < htable->capacity && htable->size > 0; i++) {
    p = htable->tab[i];

    while (p) {
      tmp = p;
      p = p->next;

      free(tmp);
      htable->size--;
    }
  }
  free(htable->tab);
  free(htable);
}

void resize_htable(struct htable *old) {
  struct htable *new = create_htable(old->capacity * 2);
  struct pair *p, *tmp, **tab2Free;


  for (size_t i = 0; i < old->capacity && old->size > 0; i++) {
    p = old->tab[i];

    while (p) {
      add_htable(new, p->key, p->value);

      tmp = p;
      p = p->next;

      free(tmp);
      old->size--;
    }
  }

  tab2Free = old->tab;

  old->capacity*= 2;
  old->size = new->size;
  old->tab = new->tab;

  free(new);
  free(tab2Free);
}

void test_htable() {
  /*
  struct htable *t = create_htable(2);
  add_htable(t, "toto", "yoloToto");
  add_htable(t, "tata", "yoloTata");
  add_htable(t, "lala", "yoloLala");
  add_htable(t, "lolo", "yoloLolo");
  add_htable(t, "dotH", "yoloDotH");
  add_htable(t, "err1", "err1");
  if (add_htable(t, "err1", "err2") != 0)
    printf("adding an existing key did not return 0\n\n");

  print_htable(t);

  struct pair *p = access_htable(t, "err1");
  printf("\n\n===== ACCESSED ======\naccessed \"err1\": %s\n", (char*)p->value);
  printf("accessed \"dotH\": %s\n", (char *)access_htable(t, "dotH")->value);
  printf("accessed \"lala\": %s\n", (char *)access_htable(t, "lala")->value);
  printf("accessed \"toto\": %s\n", (char *)access_htable(t, "lala")->value);
  if ((p = access_htable(t, "yolo")))
    printf("accessed \"yolo\" when should not: %s\n", (char *)p->value);

  printf("\n\n===== REMOVED [dotH] [lolo] [tata] =====\n");
  remove_htable(t, "dotH");
  remove_htable(t, "lolo");
  remove_htable(t, "tata");

  print_htable(t);

  clear_htable(t);
  */
  struct htable *t = create_htable(20);
  add_htable(t, "addition", addition);
  add_htable(t, "multiplication", multiplication);
  print_htable(t);

  struct pair *a = access_htable(t, "addition");
  struct pair *m = access_htable(t, "multiplication");
  printf("\nAddition 1 + 2: %d", a->value(1, 2));
  printf("\nMultiplication 2 * 2: %d\n", m->value(2, 2));

  remove_htable(t, "addition");

  print_htable(t);

  clear_htable(t);
}

