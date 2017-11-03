#include <stdio.h>
#include <glib.h>
#include "tabla.h"

int main() {
  printf("the game\n");
  SymTable *tabla = new_sym_table();
  if(insert_into(tabla, "x", INTEGER, 0))
    printf("Inserción exitosa\n");

  TableEntry *entrada = get_entry(tabla, "x");
  printf("%s, %d, %d \n", entrada->id, entrada->type, entrada->scope);
  
  return 0;
}
