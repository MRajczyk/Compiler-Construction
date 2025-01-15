%option noyywrap
%{
#include "global.h"
#include "parser.h"

int lineno = 1;
%}

%%

[ \t]   {
          /* nothing, ignore */
        }

\n      {
          lineno++;
        }

[0-9]+  {
          sscanf(yytext, "%d", &yylval);
          
          return NUM;
        }

div     {
          return DIV;
        }

mod     {
          return MOD;
        }

[a-zA-Z][a-zA-Z0-9]*  {
                        int p = lookup(yytext); 
                        if (p == 0) {
                          p = insert(yytext, ID); 
                        }
                        yylval = p; 

                        return symtable[p].token;
                      }

<<EOF>> {
          return DONE;
        }

.       {
          return yytext[0];
        }
%%

int lexan() {
  yylex();
}