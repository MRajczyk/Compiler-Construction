#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string>

#define NONE -1
#define EOS '\0'

struct symbol_t {
  std::string name;
  int token;
  int type;
  int address;
};

extern int lineno;

void error (char *m);
void init ();
void parse ();

extern int yylex();
extern int yylex_destroy(void);
