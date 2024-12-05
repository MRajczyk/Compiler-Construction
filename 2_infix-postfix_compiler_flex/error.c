#include "global.h"

void
error (char *m) 
{
  fprintf (stderr, "line%d:%s\n", lineno, m);
  yylex_destroy();
  exit (1);
}


