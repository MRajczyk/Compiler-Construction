%{
#include "global.h"
#include "parser.h"

extern int lineno;
extern void yyerror(char const *s);
extern char *yytext;
%}

%token NUM
%token DIV
%token MOD
%token ID
%token DONE

%%
parse:  expr ';'
        | %empty;

expr:   term 
        | expr '-' term { emit('-', NONE); };
        | expr '+' term { emit('+', NONE); }

term:   factor 
        | term '*' factor { emit('*', NONE); }
        | term '/' factor { emit('/', NONE); }
        | term DIV factor { emit(DIV, NONE); }
        | term MOD factor { emit(MOD, NONE); };

factor: '(' expr ')'
        | NUM { emit(NUM, $1); }
        | ID { emit(ID, $1); };
%%

void yyerror(char const *s) {
  fprintf(stderr, "%s, at token %s in line %d\n", s, yytext, lineno);
}
