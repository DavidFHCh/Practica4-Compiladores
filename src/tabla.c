#include <glib.h>
#include <stdio.h>
#include "tabla.h"

// SymTable = GHashTable de GLib
// TableEntry {
//   gchar *id;
//   gchar *type
//   Scope scope;
// }
// Scope = GLOBAL, LOCAL, PARAM

SymTable *new_sym_table() {
  return g_hash_table_new(NULL, NULL);
}

TableEntry *new_entry(gchar *id, gchar *type, Scope scope) {
  TableEntry *entry = g_new0(TableEntry, 1);
  entry->id = id;
  entry->type = type;
  entry->scope = scope;
  return entry;
}

gboolean insert_into(SymTable *table, gchar *id, gchar *type, Scope scope){
  TableEntry *entry = new_entry(id, type, scope);
  return g_hash_table_insert(table, id, entry);
}

TableEntry *get_entry(SymTable *table, gchar *id){
  return (TableEntry *)g_hash_table_lookup(table, id);
}
