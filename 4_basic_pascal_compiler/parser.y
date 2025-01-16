%{
#include "global.hpp"
#include "parser.h"

extern void yyerror(char const *s);
%}

%token DONE

%%
t:;
%%

void parse() {
  yyparse();
}

void yyerror(char const *s) {
  //error();
  fprintf(stderr, "%s, in line %d\n", s, lineno);
}
