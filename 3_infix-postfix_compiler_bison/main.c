#include "global.h"
#include "parser.h"

int
main () {
  // init ();
  yyparse ();
  yylex_destroy();
  exit (0);
}
