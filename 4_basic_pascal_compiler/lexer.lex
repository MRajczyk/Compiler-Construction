%option noyywrap
%{
#include "global.hpp"
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

<<EOF>> {
          return DONE;
        }

.       {
          return yytext[0];
        }
%%
