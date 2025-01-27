#include "global.hpp"
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>

std::stringstream out_string_stream;

void output_code(std::string code, std::string rh_code) {
  out_string_stream << "\t" << code << "\t\t;" << rh_code << std::endl;
}

void output_label(std::string label)
{
  out_string_stream << label + ":" << std::endl;
}

void export_code(std::string filename) {
  std::ofstream out_file(filename);
  out_file << out_string_stream.str();
  out_file.close();

  std::cout << out_string_stream.str() << std::endl;
}

void gencode(const std::string& m, int v1, varmode lv1, int v2, varmode lv2, int v3, varmode lv3) {
  std::string first_var = ""; 
  std::string second_var = "";

  if (symtable.at(v1).type == ID) {
    first_var = std::to_string(symtable.at(v1).address);
  }
  else {
    first_var = "#" + symtable.at(v1).name;
  }
  if (symtable.at(v2).type == ID) {
    second_var = std::to_string(symtable.at(v2).address);
  }
  else {
    second_var = "#" + symtable.at(v2).name;
  }

  std::string third_var = std::to_string(symtable.at(v3).address);

  //todo: handle
  // if(m == "write") {

  // } else if(m == "read") {

  // } else if(m == ":=") {

  // } else 
  if(m == "+") {
    generateMathCode(first_var, second_var, third_var, "add.i"); 
  } else if(m == "-") {
    generateMathCode(first_var, second_var, third_var, "sub.i"); 
  } else if(m == "*") {
    generateMathCode(first_var, second_var, third_var, "mul.i"); 
  } else if(m == "/" || m == "div") {
    generateMathCode(first_var, second_var, third_var, "div.i"); 
  } else if(m == "mod" || m =="%") {
    generateMathCode(first_var, second_var, third_var, "mod.i"); 
  }  else {
    yyerror("Operacja nieznana.");
    yylex_destroy();
    exit(1);
  }
}

void generateMathCode(std::string firstAddress, std::string secondAddress, std::string addressVar, std::string mathOperation){
  out_string_stream << "\t"+ mathOperation+ "\t" + firstAddress + ", " + secondAddress + ", " + addressVar + "\n";
}