#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#define BSIZE 128
#define NONE -1
#define EOS '\0'

extern int lineno;

void error (char *m);
void init ();
void parse ();

extern int yylex();
extern int yylex_destroy(void);
