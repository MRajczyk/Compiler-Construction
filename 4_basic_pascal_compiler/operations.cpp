#include "global.hpp"

int get_operation_token(std::string yytext) {
  if(yytext == "+") {
    return ADD;
  }
  else if(yytext == "-") {
    return SUB;
  }
  else if(yytext == "*") {
    return MUL;
  }
  else if(yytext == "/" || yytext == "div") {
    return DIV;
  }
  else if(yytext == "mod" || yytext == "%") {
    return MOD;
  }

  return -1;
}

std::string translate_tokens_to_operations(int operation_token) {
  if(operation_token == ADD) {
    return "+";
  }
  else if(operation_token == SUB) {
    return "-";
  }
  else if(operation_token == MUL) {
    return "*";
  }
  else if(operation_token == DIV) {
    return "div";
  }
  else if(operation_token == MOD) {
    return "mod";
  }

  return "";
}