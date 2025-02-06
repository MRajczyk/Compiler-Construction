#include "global.hpp"
#include <iostream>

int main (int argc, char** argv) {
  std::string filename = "compiler.output";

  init();
  parse();
  export_code(filename);
  print_symtable();
  yylex_destroy();
  exit (0);
}
