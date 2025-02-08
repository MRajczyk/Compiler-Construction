#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string>
#include <vector>
#include "parser.h"

struct array_info_t {
	int start_idx;
	int end_idx;
};

struct symbol_t {
  std::string name;         //id lub wartosc stałej liczbowej
  int token;                //kod liczbowy przypisany do tokenu
  int type;                 //typ real/int
  int address;              //adres zmiennej
  bool is_reference;        //flaga czy zmienna jest referencją
  array_info_t array_info;  //struktura informacji o zmiennej tablicowej
  bool is_global;           //flaga informująca czy zmienna jest lokalna (dla funkcji i procedur)
};

enum varmode {
  VALUE = 1,
  ADDRESS
};

enum operation_tokens {
  ADD,
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
std::string translate_tokens_to_operations(int operation_token);

void init_symtable();
void print_symtable();
int find_id(const std::string name);
int get_symbol_size(symbol_t symbol);
int get_address(std::string name);
int insert_symbol(symbol_t sym);
int insert(std::string name, int token, int type);
int new_temp(int type);
int new_num(std::string name, int type);
int get_symbol_type(int v1, varmode varmode1);
int get_result_type(int v1, int  v2);

void export_code(std::string filename);
void gencode(const std::string& m, int v1, varmode lv1, int v2, varmode lv2, int v3, varmode lv3);
void output_code(std::string code, std::string rh_code, bool additional_tab);
void output_label(std::string label);

extern int yylex();
extern void yyerror(char const *s);
extern int yylex_destroy(void);
const char *token_name(int token);
