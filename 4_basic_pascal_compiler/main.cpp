#include "global.hpp"

int main (int argc, char** argv) {
  init ();
  parse ();
  yylex_destroy();
  exit (0);
}
