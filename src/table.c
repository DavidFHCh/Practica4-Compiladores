#include <glib.h>
#include <stdio.h>
#include "table.h"

// SymTable = GHashTable de GLib
// TableEntry {
//   gchar *id;
//   gchar *type
//   Scope scope;
// }
// Scope = GLOBAL, LOCAL, PARAM
//

SymTable *new_sym_table(SymTable *father) {
  SymTable *table = g_new0(SymTable, 1);
  table->father = father;
  table->table = g_hash_table_new(g_str_hash, g_str_equal);
  return table;
}

TableEntry *new_entry(gchar *id, gchar *type, Scope scope) {
  TableEntry *entry = g_new0(TableEntry, 1);
  entry->id = id;
  entry->type = type;
  entry->scope = scope;
  return entry;
}

UncheckedSym *new_unchecked(gchar *id, SymTable *table) {
  UncheckedSym *u_sym = g_new0(UncheckedSym, 1);
  u_sym->id = id;
  u_sym->table = table;
  return u_sym;
}

gboolean insert_into(SymTable *table, gchar *id, gchar *type, Scope scope) {
  TableEntry *entry = new_entry(id, type, scope);
  return g_hash_table_insert(table->table, id, entry);
}

TableEntry *get_entry(SymTable *table, gchar *id) {
  TableEntry *entry = (TableEntry *)g_hash_table_lookup(table->table, id);
  return entry;
}

SymTable *get_father(SymTable *table) {
  return table->father;
}

TableEntry *get_entry_until_global(SymTable *table, gchar* id){
  if(table == NULL)
    return NULL;
  TableEntry *entry;
  entry = get_entry(table, id);
  if(entry != NULL)
    return entry;
  if(table->father == NULL)
    return NULL;
  return get_entry_until_global(table->father, id);
}

void serror(char* s) {
    fprintf(stderr, "THIS SYMBOL IS ALERADY DEFINED: %s.\n",s);
}

void snerror(char* s) {
    fprintf(stderr, "THIS SYMBOL HAS NOT BEING DEFINED: %s.\n",s);
}
