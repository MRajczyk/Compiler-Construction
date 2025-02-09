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
  else if(yytext == "and") {
    return AND;
  }
  else if(yytext == "=") {
    return EQ;
  }
  else if(yytext == ">=") {
    return GE;
  }
  else if(yytext == "<=") {
    return LE;
  }
  else if(yytext == "<>") {
    return NE;
  }
  else if(yytext == ">") {
    return GT;
  }
  else if(yytext == "<") {
    return LT;
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
  else if(operation_token == OR) {
    return "or";
  }
  else if(operation_token == AND) {
    return "and";
  }
  else if(operation_token == EQ) {
    return "EQ";
  }
  else if(operation_token == GE) {
    return "GE";
  }
  else if(operation_token == LE) {
    return "LE";
  }
  else if(operation_token == NE) {
    return "NE";
  }
  else if(operation_token == GT) {
    return "GT";
  }
  else if(operation_token == LT) {
    return "LT";
  }

  return "";
}