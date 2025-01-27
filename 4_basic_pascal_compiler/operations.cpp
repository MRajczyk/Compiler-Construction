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