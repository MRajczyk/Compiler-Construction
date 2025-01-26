#include "global.hpp"
#include "parser.h"

int main (int argc, char** argv) {
  init ();
  parse ();
  yylex_destroy();
  exit (0);
}
