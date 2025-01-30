#include "global.hpp"
#include <iostream>

int main (int argc, char** argv) {
  // todo: future
  // if(argc < 2) {
  //   printf("Nie podano nazwy pliku jako parametr.");
  // }
  // std::string filename = argv[1];
  std::string filename = "compiler.output";

  init();
  parse();
  export_code(filename);
  print_symtable();
  yylex_destroy();
  exit (0);
}
