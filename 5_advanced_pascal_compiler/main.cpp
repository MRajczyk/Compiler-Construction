#include "global.hpp"
#include <iostream>

std::fstream out_file_stream;

int main (int argc, char** argv) {
  std::string filename = "compiler.output";
  out_file_stream.open(filename, std::fstream::out);
  if (!out_file_stream) {
    std::cerr << "Nie można otworzyć pliku do zapisu!" << std::endl;
    return 1;
  }

  init();
  parse();
  export_code(filename);
  out_file_stream.close();

  std::cout << "Global symtable:" << std::endl;
  print_symtable();
  std::cout << std::endl;

  std::ifstream file(filename);
  if (!file) {
    std::cerr << "Nie można otworzyć pliku do odczytu!" << std::endl;
    return 1;
  }

  std::string line;
  while (std::getline(file, line)) {
    std::cout << line << std::endl; 
  }
  file.close();
  std::cout << std::endl; 
  yylex_destroy();
  
  return 0;
}
