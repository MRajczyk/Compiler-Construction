%{
#include "global.h"
#include "parser.h"

extern int lineno;
extern void yyerror(char const *s);
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
        | expr '+' term { printf("+\n"); }
        | expr '-' term { printf("-\n"); };

term:   factor 
        | term '*' factor { printf("*\n"); }
        | term '/' factor { printf("/\n"); }
        | term DIV factor { printf("DIV\n"); }
        | term MOD factor { printf("MOD\n"); };

factor: '(' expr ')'
        | NUM { printf("%d\n", $1); }
        | ID { printf("%s\n", symtable[$1].lexptr); };
%%

void yyerror(char const *s) {
  fprintf(stderr, "%s\n, in line %d", s, lineno);
}

