#include <glib.h>

// Nuestra tabla de símbolos será solamente un diccionario de GLib
typedef GHashTable SymTable;

typedef enum _type {
  INTEGER,
  STRING
} Type;

typedef struct _entry {
  gchar *id;
  Type type;
  gint scope;
  
} TableEntry;

SymTable *new_sym_table();
gboolean insert_into(SymTable*, gchar*, Type, gint);
TableEntry *get_entry(SymTable*, gchar*);
