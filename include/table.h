#include <glib.h>

// Nuestra tabla de símbolos será solamente un diccionario de GLib
typedef struct _sym_table {
  struct _sym_table *father;
  GHashTable *table;
} SymTable;


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
  gchar *type;
  Scope scope;
} TableEntry;

void serror (char*);
void snerror (char*);

SymTable *new_sym_table(SymTable*);
gboolean insert_into(SymTable*, gchar*, gchar*, Scope);
TableEntry *get_entry(SymTable*, gchar*);
SymTable *get_father(SymTable*);
TableEntry *get_entry_until_global(SymTable*, gchar*);
