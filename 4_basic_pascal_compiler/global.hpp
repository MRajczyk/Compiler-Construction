#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string>
#include <vector>
#include "parser.h"

struct symbol_t {
  std::string name;
  int token;
  int type;
  int address;
};

extern std::vector<symbol_t> symtable;
extern int lineno;

void error (char *m);
void init ();
void parse ();

extern int yylex();
extern void yyerror(char const *s);
extern int yylex_destroy(void);
