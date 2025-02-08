#include "global.hpp"
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>

std::stringstream out_string_stream;

void output_code(std::string code, std::string rh_code, bool additional_tab) {
  out_string_stream << "\t" << code << (additional_tab ? "\t" : "") << "\t;" << rh_code << std::endl;
}

void output_label(std::string label) {
  out_string_stream << label + ":" << std::endl;
}

void export_code(std::string filename) {
  std::ofstream out_file(filename);
  out_file << out_string_stream.str();
  out_file.close();
  
  std::cout << out_string_stream.str() << std::endl;
}

std::string get_operation_suffix(int v1, varmode varmode1, int v2, varmode varmode2) {
  if(get_symbol_type(v1, varmode1) == REAL || get_symbol_type(v2, varmode2) == REAL) {
    return ".r";
  }

  return ".i";
}

void cast_to_same_type(int& v1, varmode varmode1, int& v2, varmode varmode2) {
  int type_v1 = get_symbol_type(v1, varmode1);
  int type_v2 = get_symbol_type(v2, varmode2);

  if(type_v1 == type_v2) {
    return;
  } 
  if(type_v1 == INTEGER && type_v2 == REAL) {
    int new_var = new_temp(REAL);
    gencode("inttoreal", v1, varmode1, -1, VALUE, new_var, VALUE);
    v1 = new_var;
  }
  else if(type_v1 == REAL && type_v2 == INTEGER) {
    int new_var = new_temp(REAL);
    gencode("inttoreal", v2, varmode2, -1, VALUE, new_var, VALUE);
    v2 = new_var;
  } else {
    yyerror("Błąd w przypisanych typach.");
    yylex_destroy();
    exit(1);
  }
}

bool cast_to_same_type_on_assign(int v1, varmode varmode1, int v2, varmode varmode2) {
  int type_v1 = get_symbol_type(v1, varmode1);
  int type_v2 = get_symbol_type(v2, varmode2);

  if(type_v1 == type_v2) {
    return false;
  }
  if(type_v1 == INTEGER && type_v2 == REAL) {
    gencode("inttoreal", v1, varmode1, -1, VALUE, v2, VALUE);
    return true;
  }
  else if(type_v1 == REAL && type_v2 == INTEGER) {
    gencode("realtoint", v1, varmode2, -1, VALUE, v2, VALUE);
    return true;
  } else {
    yyerror("Błąd w przypisanych typach.");
    yylex_destroy();
    exit(1);
  }
}

void gencode(const std::string& m, int v1, varmode lv1, int v2, varmode lv2, int v3, varmode lv3) {
  std::string first_var; 
  std::string second_var;
  std::string first_var_name; 
  std::string second_var_name;
  std::string type_suffix;
  
  if(m == "read" || m == "write" || m == "assign") {
    type_suffix = get_operation_suffix(v1, lv1, v3, lv3);
  }
  else {
    type_suffix = get_operation_suffix(v1, lv1, v2, lv2);
  }

  if(m == "+" || m == "-" || m == "*" || m == "/" || m == "div" || m == "mod" || m == "%") {
    cast_to_same_type(v1, lv1, v2, lv2);
  }

  if(v1 != -1) {
    if (symtable.at(v1).token == VAR || symtable.at(v1).token == ARRAY) {
      first_var = std::to_string(symtable.at(v1).address);
      first_var_name = symtable.at(v1).name;
    }
    else {
      first_var = "#" + symtable.at(v1).name;
      first_var_name = symtable.at(v1).name;
    }
  }
  if(v2 != -1) {
    if (symtable.at(v2).token == VAR || symtable.at(v2).token == ARRAY) {
      second_var = std::to_string(symtable.at(v2).address);
      second_var_name = symtable.at(v2).name;
    }
    else {
      second_var = "#" + symtable.at(v2).name;
      second_var_name = symtable.at(v2).name;
    }
  }

  std::string third_var = std::to_string(symtable.at(v3).address);
  std::string third_var_name = symtable.at(v3).name;

  if(m == "+") {
    output_code("add" + type_suffix + "\t" + first_var + ", " + second_var + ", " + third_var, "add" + type_suffix + "\t" + first_var_name + ", " + second_var_name + ", " + third_var_name, false);
  } else if(m == "-") {
    output_code("sub" + type_suffix + "\t" + first_var + ", " + second_var + ", " + third_var, "sub" + type_suffix + "\t" + first_var_name + ", " + second_var_name + ", " + third_var_name, false);
  } else if(m == "*") {
    output_code("mul" + type_suffix + "\t" + first_var + ", " + second_var + ", " + third_var, "mul" + type_suffix + "\t" + first_var_name + ", " + second_var_name + ", " + third_var_name, false);
  } else if(m == "/" || m == "div") {
    output_code("div" + type_suffix + "\t" + first_var + ", " + second_var + ", " + third_var, "div" + type_suffix + "\t" + first_var_name + ", " + second_var_name + ", " + third_var_name, false);
  } else if(m == "mod" || m =="%") {
    output_code("mod" + type_suffix + "\t" + first_var + ", " + second_var + ", " + third_var, "mod" + type_suffix + "\t" + first_var_name + ", " + second_var_name + ", " + third_var_name, false);
  } else if(m == "write") {
    output_code("write" + type_suffix + "\t" + third_var, "write" + type_suffix + " " + third_var_name, true);
  } else if(m == "read") {
    output_code("read" + type_suffix + "\t" + third_var, "read" + type_suffix + "\t" + third_var_name, true);
  } else if(m == "assign") {
    if(cast_to_same_type_on_assign(v1, lv1, v3, lv3)) {
      return;
    }
    else {
      output_code("mov" + type_suffix + "\t" + first_var + ", " + third_var, "mov" + type_suffix + "\t" + first_var_name + ", " + third_var_name, true);
    }
  } else if(m == "inttoreal") {
    output_code("inttoreal.i " + first_var + ", " + third_var, "inttoreal.i " + first_var_name + ", " + third_var_name, false);
  } else if(m == "realtoint") {
    output_code("realtoint.r " + first_var + ", " + third_var, "realtoint.r " + first_var_name + ", " + third_var_name, false);
  }
  else {
    yyerror("Operacja nieznana.");
    yylex_destroy();
    exit(1);
  }
}
