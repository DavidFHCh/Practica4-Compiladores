%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "table.h"
#include <glib.h>

void yyerror (char*);
int yylex();
int empty;
int errors = 0;
extern FILE *yyin;
extern char* yytext;
extern FILE* yyout;
extern int yylineno;
char *result;

SymTable* top;
SymTable* aux;

GList *later = NULL;

%}


%start program
%union {
    char* string_t;
    int integer_t;
    char* program_t;
    char* class_t;
    char* feature_t;
    char* formal_t;
    char* expr_t;
    char* list_t;
}
%token CLASS TYPE ID INHERITS SUPER IF ELSE WHILE SWITCH CASE VALUE BREAK DEFAULT NEW RETURN INTEGER STRING TRUE_Y FALSE_Y NULL_Y
%nonassoc '<' EQ LE
%left '+' '-'
%left '*' '/'
%type<string_t> TYPE ID STRING
%type<integer_t> INTEGER
%type<program_t> program
%type<class_t> class
%type<feature_t> feature
%type<formal_t> formal
%type<expr_t> expr default expr_arg_list
%type<list_t> feature_list formal_list expr_list case_list
%%

program :
    class       { char *s = malloc(1024);
                  sprintf(s, "%s\n", $1);
                  result = s;
                  $$ = s; }
    | program class
                { char *s = malloc(1024);
                  sprintf(s, "%s \n%s", $1, $2);
                  $$ = s; }
    ;

class:
    CLASS TYPE '{'
            {
                //P04
                top = new_sym_table(NULL);
                insert_into(top,"this",$2,GLOBAL);
            }
  feature_list '}'
                { char *s = malloc(1024);
                  sprintf(s, "[CLASS %s \n\t%s]", $2, $5);
                  $$ = s; }
    | CLASS TYPE INHERITS TYPE '{'
            {
                //P04
                top = new_sym_table(NULL);
                insert_into(top,"this",$2,GLOBAL);
            }
                  feature_list '}'
                { char *s = malloc(1024);
                  sprintf(s, "\n[CLASS %s OF %s \n\t%s]", $2, $4, $7);
                  $$ = s; }
    ;

feature_list :
    %empty      { $$ = ""; }
    | feature_list feature
                { char *s = malloc(1024);
                  sprintf(s, "%s \n%s", $1, $2);
                  $$ = s; }
    ;

feature :
    TYPE ID '('
            {
                //P04
                if (get_entry_until_global(top,$2) != NULL)
                    serror($2);
                else
                    insert_into(top,$2,$1,GLOBAL);
                aux = new_sym_table(top);
                top = aux;
            }
    formal_list ')' '{' expr_list RETURN expr ';' '}'
                { char *s = malloc(1024);
                  sprintf(s, "\n[METHOD %s %s \n\t%s \n\t%s \n[RETURN %s]]", $2, $1, $5, $8, $10);
                  $$ = s; }
    | TYPE ID ';'
                { char *s = malloc(1024);
                  sprintf(s, "\n[ATTRIBUTE %s %s]", $2, $1);
                  $$ = s;
                  //P04
                  if (get_entry_until_global(top,$2) != NULL)
                      serror($2);
                  else
                      insert_into(top,$2,$1,GLOBAL);
                }
    | TYPE ID
        {
            //P04
            if (get_entry_until_global(top,$2) != NULL)
                serror($2);
            else
                insert_into(top,$2,$1,GLOBAL);
        }
         '=' expr ';'
                { char *s = malloc(1024);
                  sprintf(s, "\n[ATTRIBUTE_ASSIGNMENT %s %s %s]", $2, $1, $5);
                  $$ = s; }
    ;

formal_list :
    %empty      { $$ = ""; }
    | formal    { $$ = $1; }
    | formal_list ',' formal
                { char *s = malloc(1024);
                  sprintf(s, "%s \n%s", $1, $3);
                  $$ = s; }
    ;

expr_list :
    %empty      { $$ = ""; }
    | expr_list expr ';'
                { char *s = malloc(1024);
                  sprintf(s, "%s %s", $1, $2);
                  $$ = s; }
    ;

formal :
    TYPE ID     { char *s = malloc(256);
                  sprintf(s, "\n[FORMAL %s %s]\n", $2, $1);
                  $$ = s;
                  //P04
                  if (get_entry_until_global(top,$2) != NULL)
                      serror($2);
                  else
                      insert_into(top,$2,$1,PARAM);
                }
    ;

case_list :
    %empty      { $$ = ""; }
    | case_list CASE INTEGER ':' expr_list BREAK ';'
                { char *s = malloc(1024);
                  sprintf(s, "%s \n[CASE %d \n\t%s]", $1, $3, $5);
                  $$ = s; }
    ;

default :
    DEFAULT ':' expr_list
                { char *s = malloc(1024);
                  sprintf(s, "\n[DEFAULT \n\t%s]", $3);
                  $$ = s; }
    ;

expr :
    ID
    {
        if (get_entry_until_global(top,$1) == NULL)
            later = g_list_insert (later,$1,-1);
    }
        '=' expr { char *s = malloc(1024);
                  sprintf(s, "\n[ASSIGN %s %s]", $1, $4);
                  $$ = s; }
    | expr '.' ID
    {
        if (get_entry_until_global(top,$3) == NULL)
            later = g_list_insert (later,$3,-1);
    }
     '(' expr_arg_list ')'
                { char *s = malloc(1024);
                  sprintf(s, "\n[CALL %s %s %s]", $1, $3, $6);
                  $$ = s; }
    | expr '.' SUPER '.' ID
    {
        if (get_entry_until_global(top,$5) == NULL)
            later = g_list_insert (later,$1,-1);
    }
     '(' expr_arg_list ')'
                { char *s = malloc(1024);
                  sprintf(s, "\n[SUPER_CALL %s %s %s]", $1, $5, $8);
                  $$ = s; }
    | ID
    {
        if (get_entry_until_global(top,$1) == NULL)
            later = g_list_insert (later,$1,-1);
    }
    '(' expr_arg_list ')'
                { char *s = malloc(1024);
                  sprintf(s, "\n[CALL %s %s]", $1, $4);
                  $$ = s; }
    | IF '(' expr ')' '{' expr_list '}'
                { char *s = malloc(1024);
                  sprintf(s, "\n[IF %s %s]", $3, $6);
                  $$ = s; }
    | IF '(' expr ')' '{' expr_list '}' ELSE '{' expr_list '}'
                { char *s = malloc(1024);
                  sprintf(s, "\n[IF_ELSE %s %s %s]", $3, $6, $10);
                  $$ = s; }
    | WHILE '(' expr ')' '{' expr_list '}'
                { char *s = malloc(1024);
                  sprintf(s, "\n[WHILE %s %s]", $3, $6);
                  $$ = s; }
    | SWITCH '(' ID
    {
        if (get_entry_until_global(top,$3) == NULL)
            later = g_list_insert (later,$3,-1);
    }
     ')' '{' case_list default '}'
                { char *s = malloc(1024);
                  sprintf(s, "\n[SWITCH %s %s %s]", $3, $7, $8);
                  $$ = s; }
    | NEW TYPE
                { char *s = malloc(1024);
                  sprintf(s, "\n[NEW %s]", $2);
                  $$ = s; }
    | expr '+' expr
                { char *s = malloc(1024);
                  sprintf(s, "\n[ADD %s %s]", $1, $3);
                  $$ = s; }
    | expr '-' expr
                { char *s = malloc(1024);
                  sprintf(s, "\n[MIN %s %s]", $1, $3);
                  $$ = s; }
    | expr '*' expr
                { char *s = malloc(1024);
                  sprintf(s, "\n[MUL %s %s]", $1, $3);
                  $$ = s; }
    | expr '/' expr
                { char *s = malloc(1024);
                  sprintf(s, "\n[DIV %s %s]", $1, $3);
                  $$ = s; }
    | expr '<' expr
                { char *s = malloc(1024);
                  sprintf(s, "\n[LT %s %s]", $1, $3);
                  $$ = s; }
    | expr LE expr
                { char *s = malloc(1024);
                  sprintf(s, "\n[LE %s %s]", $1, $3);
                  $$ = s; }
    | expr EQ expr
                { char *s = malloc(1024);
                  sprintf(s, "\n[EQ %s %s]", $1, $3);
                  $$ = s; }
    | '!' expr  { char *s = malloc(512);
                  sprintf(s, "\n[NEGATION %s]", $2);
                  $$ = s; }
    | '(' expr ')'
                { $$ = $2; }
    | ID
    {
        if (get_entry_until_global(top,$1) == NULL){
            later = g_list_insert (later,$1,-1);
        }
    }
         { char* s = malloc(512);
                  sprintf(s, "\n[ID %s]", $1);
                  $$ = s; }
    | INTEGER   { char* s = malloc(512);
                  sprintf(s, "\n[CONSTANT %d]", $1);
                  $$ = s; }
    | STRING    { char* s = malloc(512);
                  sprintf(s, "\n[CONSTANT STRING %s]", $1);
                  $$ = s; }
    | TRUE_Y    { $$ = "\n[CONSTANT TRUE]"; }
    | FALSE_Y   { $$ = "\n[CONSTANT FALSE]"; }
    ;

expr_arg_list :
    %empty      { $$ = ""; }
    | expr      { $$ = $1; }
    | expr_arg_list ',' expr
                { char *s = malloc(1024);
                  sprintf(s, "%s \n%s", $1, $3);
                  $$ = $3; }
    ;
%%


void yyerror(char* s) {
    errors++;
    fprintf(stderr, " SYNTAX ERROR AT %d: '%s'\n\t%s\n",yylineno,yytext,s);
}

void later_check () {
    GList *elem;
    char *item;
    //gint i = g_list_length (later);
    //fprintf(stderr,"%d\n",i);
    for (elem = later; elem; elem = elem->next) {
        item = elem -> data;
        //fprintf(stderr,"%s\n",item);
        if (get_entry_until_global(top,item) == NULL) {
            snerror(item);
        }
    }
}

int main (int argc, char* argv[]){
    if (argc < 3) {
        printf("If you don't know how to use this, read the README.");
        return 1;
    }
    yyin = fopen(argv[1],"r");
    yyout = fopen(argv[2], "w");
    yyparse();
    fclose(yyin);
    later_check();
    if(errors) {
        printf("The program contains %d errors. PLEASE correct them.",errors);
    } else {
        fwrite(result, 1, strlen(result), yyout);
        fclose(yyout);
    }
    return 0;
}
