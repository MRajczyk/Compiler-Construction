#include "global.hpp"
#include <iostream>

std::fstream out_file_stream;

int main (int argc, char** argv) {
  std::string filename = "compiler.output";
  out_file_stream.open(filename, std::fstream::out);

  init();
  parse();
  export_code(filename);
  out_file_stream.close();

  std::cout << "Global symtable:" << std::endl;
  print_symtable();
  std::cout << std::endl;

  //todo: refactor!
  std::ifstream file("compiler.output");
  if (!file) {
      std::cerr << "Nie można otworzyć pliku!" << std::endl;
      return 1;
  }
  std::string line;
  while (std::getline(file, line)) {
    std::cout << line << std::endl; 
  }
  file.close();
  std::cout << std::endl; 
  yylex_destroy();
  exit (0);
}
