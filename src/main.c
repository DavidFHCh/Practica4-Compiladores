#include <stdio.h>
#include <glib.h>
#include "table.h"

int main() {
  printf("the game\n");
  SymTable *tabla = new_sym_table(NULL);
  if(insert_into(tabla, "x", "INTEGER", GLOBAL))
    printf("Inserción exitosa\n");

  TableEntry *entrada = get_entry_until_global(tabla, "X");
  if(entrada != NULL)
    printf("%s, %s, %d \n", entrada->id, entrada->type, entrada->scope);
  SymTable *tabla2 = new_sym_table(tabla);
  TableEntry *entrada2 = get_entry_until_global(tabla2, "x");
  if(entrada2 != NULL)
    printf("%s, %s, %d \n", entrada2->id, entrada2->type, entrada2->scope);
  SymTable *tabla3 = new_sym_table(tabla2);
  TableEntry *entrada3 = get_entry_until_global(tabla3, "x");
    printf("%s, %s, %d \n", entrada3->id, entrada3->type, entrada3->scope);
  return 0;
}
