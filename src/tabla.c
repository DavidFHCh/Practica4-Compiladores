#include <glib.h>
#include <stdio.h>
#include "tabla.h"


SymTable *new_sym_table() {
  return g_hash_table_new(NULL, NULL);
}
