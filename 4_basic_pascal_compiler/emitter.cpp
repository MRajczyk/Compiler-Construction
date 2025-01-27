#include "global.hpp"
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>

std::stringstream out_string_stream;

void output_code(std::string code, std::string rh_code, bool additional_tab) {
  out_string_stream << "\t" << code << (additional_tab ? "\t" : "") << "\t;" << rh_code << std::endl;
}

void output_label(std::string label)
{
  out_string_stream << label + ":" << std::endl;
}

void export_code(std::string filename) {
  std::ofstream out_file(filename);
  out_file << out_string_stream.str();
  out_file.close();

  //print generated code
  std::cout << out_string_stream.str() << std::endl;
}

void gencode(const std::string& m, int v1, varmode lv1, int v2, varmode lv2, int v3, varmode lv3) {
  std::string first_var = ""; 
  std::string second_var = "";
  std::string first_var_name = ""; 
  std::string second_var_name = "";

  if (symtable.at(v1).token == VAR) {
    first_var = std::to_string(symtable.at(v1).address);
    first_var_name = symtable.at(v1).name;
  }
  else {
    first_var = "#" + symtable.at(v1).name;
    first_var_name = symtable.at(v1).name;
  }
  if (symtable.at(v2).token == VAR) {
    second_var = std::to_string(symtable.at(v2).address);
    second_var_name = symtable.at(v2).name;
  }
  else {
    second_var = "#" + symtable.at(v2).name;
    second_var_name = symtable.at(v2).name;
  }

  std::string third_var = std::to_string(symtable.at(v3).address);
  std::string third_var_name = symtable.at(v3).name;
  if(m == "+") {
    output_code("add.i\t" + first_var + ", " + second_var + ", " + third_var, "add.i\t" + first_var_name + ", " + second_var_name + ", " + third_var_name, false);
  } else if(m == "-") {
    output_code("sub.i\t" + first_var + ", " + second_var + ", " + third_var, "add.i\t" + first_var_name + ", " + second_var_name + ", " + third_var_name, false);
  } else if(m == "*") {
    output_code("mul.i\t" + first_var + ", " + second_var + ", " + third_var, "add.i\t" + first_var_name + ", " + second_var_name + ", " + third_var_name, false);
  } else if(m == "/" || m == "div") {
    output_code("div.i\t" + first_var + ", " + second_var + ", " + third_var, "add.i\t" + first_var_name + ", " + second_var_name + ", " + third_var_name, false);
  } else if(m == "mod" || m =="%") {
    output_code("mod.i\t" + first_var + ", " + second_var + ", " + third_var, "add.i\t" + first_var_name + ", " + second_var_name + ", " + third_var_name, false);
  }  else {
    yyerror("Operacja nieznana.");
    yylex_destroy();
    exit(1);
  }
}
