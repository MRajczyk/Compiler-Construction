#include "global.hpp"
#include "parser.h"

int main () {
  init ();
  parse ();
  yylex_destroy();
  exit (0);
}
