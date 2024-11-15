#include "global.h"

int
main () 
{
  init ();
  parse ();
  yylex_destroy();
  exit (0);
}


