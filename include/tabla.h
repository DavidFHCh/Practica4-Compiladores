#include <glib.h>

// Nuestra tabla de símbolos será solamente un diccionario de GLib
typedef GHashTable SymTable;

typedef enum _type {
  INTEGER,
  STRING
} Type;

typedef enum _scope {
  GLOBAL,
  LOCAL,
  PARAM
} Scope;

// Una entrada de la tabla es un identificador, un tipo y un alcance
// El tipo probablemente tenga que cambiar porque los tipos también
// incluyen los definidos por el usuario.
// El alcance se expresa como un enumerador con tres posibles
// valores: global, local y parámetro.

typedef struct _entry {
  gchar *id;
  Type type;
  Scope scope;
} TableEntry;

SymTable *new_sym_table();
gboolean insert_into(SymTable*, gchar*, Type, Scope);
TableEntry *get_entry(SymTable*, gchar*);
