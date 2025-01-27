#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string>
#include <vector>
#include "parser.h"

struct symbol_t {
  std::string name; //id lub wartosc stałej liczbowej
  int token;        //kod liczbowy przypisany do tokenu - parser.h
  int type;         //typ zmiennej - real/int
  int address;      //adres zmiennej
};

enum num_type {
  VAR_REAL = 1,
  VAR_INTEGER
};

enum varmode {
  VALUE = 1,
  ADDRESS
};

enum operation_tokens {
  ADD = 1,
  SUB,
  MUL,
  DIV,
  MOD
};

extern std::vector<symbol_t> symtable;
extern int lineno;

void init ();
void parse ();

int get_operation_token(std::string yytext);

void init_symtable();
int find_id(const std::string name);
int get_symbol_size(symbol_t symbol);
int get_address(std::string name);
int insert_symbol(symbol_t sym);
int insert(std::string name, int token, int type);
int new_temp(int type);
int new_num(std::string name, int type);

void export_code(std::string filename);
void gencode(const std::string& m, int v1, varmode lv1, int v2, varmode lv2, int v3, varmode lv3);
void generateMathCode(std::string firstAddress, std::string secondAddress, std::string addressVar, std::string mathOperation);
void output_code(std::string code, std::string rh_code);
void output_label(std::string label);

extern int yylex();
extern void yyerror(char const *s);
extern int yylex_destroy(void);
