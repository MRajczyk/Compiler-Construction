#include "global.hpp"
#include <iostream>
#include <fstream>
#include <sstream>

std::stringstream out_string_stream;

void export_code(std::string filename) {
  std::ofstream out_file(filename);
  out_file << out_string_stream.str();
  out_file.close();

  std::cout << out_string_stream.str() << std::endl;
}