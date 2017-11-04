%{
#include <stdlib.h>
#include <string.h>
#include "looli.h"


char* buffer;
void clean();
void error (char*);

%}

letter [A-Za-z]
digit [0-9]
whitespace [ \f\r\t\v]
operator [-+*/<!]
symbol [.,:;(){}=]
%x string
%x comment
%%

\n                                      ++yylineno;
{whitespace}+                           ;
"class"                                 return CLASS;
"inherits"                              return INHERITS;
"return"                                return RETURN;
"super"                                 return SUPER;
"if"                                    return IF;
"else"                                  return ELSE;
"switch"                                return SWITCH;
"case"                                  return CASE;
"break"                                 return BREAK;
"default"                               return DEFAULT;
"while"                                 return WHILE;
"new"                                   return NEW;
"int"|"boolean"                         {   yylval.string_t = strdup(yytext);
                                            return TYPE;
                                        }
[A-Z]({digit}|{letter}|"_")*            {   yylval.string_t = strdup(yytext);
                                            return TYPE;
                                        }
"true"                                  return TRUE_Y;
"false"                                 return FALSE_Y;
"null"                                  return NULL_Y;
{digit}+                                {   yylval.integer_t = atoi(yytext);
                                            return INTEGER;
                                        }
"this"                                  {   yylval.string_t = strdup(yytext);
                                            return ID;
                                        }
({digit}|{letter}|"_")+                 {   yylval.string_t = strdup(yytext);
                                            return ID;
                                        }
{symbol}                                return *yytext;
{operator}                              return *yytext;
"<="                                    return LE;
"=="                                    return EQ;
\"                                      {   clean();
                                            strcat(buffer,yytext);
                                            BEGIN(string);
                                        }
<string>(\\.|[^\\"\0\n])*               strcat(buffer,yytext);
<string>\"                              {   strcat(buffer,yytext);
                                            yylval.string_t = strdup(yytext);
                                            BEGIN(INITIAL);
                                            return STRING;
                                        }
<string>\n                              {   BEGIN(INITIAL);
                                            error("There is a newline character in the String.");
                                            yylineno++;
                                        }
<string>\0                              {   BEGIN(INITIAL);
                                            error("End of string in String.");
                                        }
<string><<EOF>>                         {   BEGIN(INITIAL);
                                            error("End of File in String.");
                                        }
"//"(.)*\n                              yylineno++;
"/*"                                    BEGIN(comment);
<comment>\n                             yylineno++;
<comment>[^*\n]                         ;
<comment>"*"+[^*/\n]*                   ;
<comment>"*/"                           BEGIN(INITIAL);
.                                       error("I have no idea of what this is.");
%%
int yywrap (void) {
  return 1;
}


void clean (int f) {
    free(buffer);
    buffer = malloc (sizeof (char));
    buffer[0] = '\0';
}

void error (char* s) {
    fprintf(stderr, "+++++++++++++++++++++++++\nLexic error at line: %d: '%s'\n\t%s\n+++++++++++++++++++++++++", yylineno, yytext, s);
}
