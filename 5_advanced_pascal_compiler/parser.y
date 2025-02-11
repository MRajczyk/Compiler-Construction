%{
#include "global.hpp"
#include <iostream>

std::vector<int> ids_list;
std::list<std::pair<int, array_info_t>> fun_proc_arguments;
std::list<int> params_address_translation_list;
array_info_t array_info;
const int fun_return_address = 8;
const int fun_parameter_start_offset = 12;
const int proc_parameter_start_offset = 8;
const int argument_size = 4; //sizeof address (integer)
int arguments_offset = 0;

%}
%token PROGRAM

%token NUM           
%token ID

%token VAR
%token INTEGER
%token REAL
%token LABEL

%token BEGIN_TOKEN
%token END_TOKEN

%token OPERATOR
%token ASSIGNOP

%token READ
%token WRITE

%token ARRAY 
%token OF

%token FUNCTION
%token PROCEDURE

%token IF
%token THEN
%token ELSE
%token WHILE
%token DO

%token SIGN
%token RELOP
%token MULOP
%token OR
%token ADDOP

%token NOT
%token NONE
%token DONE

%%
program:
  PROGRAM ID {
    output_code("jump.i\t#lab0", "jump.i lab0", true);
  }
  '(' identifier_list ')' ';' {
    for(auto symTabIdx : ids_list) {
      symbol_t* sym = &symtable[symTabIdx];
      sym->token = VAR;
      sym->type = NONE;
      sym->address = 0;
    }
    ids_list.clear();
  }
  declarations
  subprogram_declarations {
    output_label("lab0");
  }
  compound_statement
  '.' DONE {
    output_code("exit\t", "exit", true);
    return 0;
  }
  ;

identifier_list:
  ID {
    ids_list.push_back($1);
  }
  | identifier_list ',' ID {
    ids_list.push_back($3);
  }
  ;

declarations:       
  declarations VAR identifier_list ':' type ';' {
    for(auto symTabIdx : ids_list) {
        if($5 == INTEGER || $5 == REAL) {
        symbol_t* sym = &symtable[symTabIdx];
        sym->token = VAR;
        sym->type = $5;
        sym->address = update_curr_address(get_symbol_size(*sym));
      }
      else if ($5 == ARRAY) {
        symbol_t* sym = &symtable[symTabIdx];
        sym->token = $5;
        sym->type = array_info.element_type;
        sym->array_info = array_info;
        sym->address = update_curr_address(get_symbol_size(*sym));
      }
      else {
        yyerror("Incorrect variable declaration type");
      }
    }
    ids_list.clear();
  }
  | %empty
  ;

type:               
  standard_type
  | ARRAY '[' NUM '.' '.' NUM ']' OF standard_type {
    $$ = ARRAY;
    array_info.element_type = $9;
    array_info.start_idx = atoi(symtable[$3].name.c_str());
    array_info.end_idx = atoi(symtable[$6].name.c_str());
  }
  ;

standard_type:
  INTEGER {
    $$ = INTEGER;
  }
  | REAL {
    $$ = REAL;
  }
  ;

subprogram_declarations:
  subprogram_declarations subprogram_declaration ';'
  | %empty
  ;

subprogram_declaration:
  subprogram_head declarations compound_statement {
    //block ran after fun/proc declaration
    gencode("leave", -1, VALUE, -1, VALUE, -1, VALUE);
    gencode("return", -1, VALUE, -1, VALUE, -1, VALUE);
    std::cout << "Symtable for function " << symtable[$1].name << ":" << std::endl;
    print_symtable();
    std::cout << std::endl;

    //clear all temp values
    clear_local_symbols();
    is_global = true;
    arguments_offset = 0;
    curr_address_local = 0;
  }
  ;

subprogram_head:
  FUNCTION ID {
    is_global = false;
    symtable[$2].token = FUNCTION;
    arguments_offset = fun_parameter_start_offset;
    gencode("fun", -1, VALUE, -1, VALUE, $2, VALUE);
  }
  arguments {
    symtable[$2].arguments = fun_proc_arguments;
    fun_proc_arguments.clear();
  }
  ':' standard_type {
    symtable[$2].type = $7;
    int return_var_idx = insert(symtable[$2].name, VAR, $7);
    symtable[return_var_idx].is_reference = true;
    symtable[return_var_idx].address = fun_return_address;
  }
  ';' {
    $$ = $2;
  }
  | PROCEDURE ID {
    is_global = false;
    symtable[$2].token = PROCEDURE;
    arguments_offset = proc_parameter_start_offset;
    gencode("proc", -1, VALUE, -1, VALUE, $2, VALUE);
  }
  arguments {
    symtable[$2].arguments = fun_proc_arguments;
    fun_proc_arguments.clear();
  }
  ';' {
    $$ = $2;
  }
  ;

arguments:
  '(' parameter_list ')' {
    for(auto idx : params_address_translation_list) {
      symtable[idx].address = arguments_offset;
      arguments_offset += argument_size;
    }
    params_address_translation_list.clear();
  }
  | %empty
  ;

parameter_list:     
  identifier_list ':' type {
    for(auto idx : ids_list) {
      symtable[idx].is_reference = true;
      if($3 == ARRAY) {
        symtable[idx].token = ARRAY;
        symtable[idx].type = array_info.element_type;
        symtable[idx].array_info = array_info;
      }
      else {
        symtable[idx].token = VAR;
        symtable[idx].type = $3;
      }
      fun_proc_arguments.push_back(std::make_pair($3, array_info));
      params_address_translation_list.push_front(idx);
    }
    ids_list.clear();
  }
  | parameter_list ';' identifier_list ':' type {
    for(auto idx : ids_list) {
      symtable[idx].is_reference = true;
      if($5 == ARRAY) {
        symtable[idx].token = ARRAY;
        symtable[idx].type = array_info.element_type;
        symtable[idx].array_info = array_info;
      }
      else {
        symtable[idx].token = VAR;
        symtable[idx].type = $5;
      }
      fun_proc_arguments.push_back(std::make_pair($5, array_info));
      params_address_translation_list.push_front(idx);
    }
    ids_list.clear();
  }
  ;

compound_statement: 
  BEGIN_TOKEN
  optional_statements 
  END_TOKEN
  ;

optional_statements: 
  statement_list
  | %empty
  ;

statement_list:     
  statement
  | statement_list ';' statement
  ;

statement:
  variable ASSIGNOP expression {
    if(symtable.at($1).token != VAR && symtable.at($1).token != ARRAY) {
      fprintf(stderr, "Error, Attempted write to an undeclared variable: %s, in line %d\n", symtable.at($1).name.c_str(), lineno - 1);
      yylex_destroy();
      return -1;
    }
    gencode("assign", $3, VALUE, -1, VALUE, $1, VALUE);
  }
  | procedure_statement
  | compound_statement
  | IF expression {
    int label1_idx = new_label();
    int expr_false = new_num("0", INTEGER);
    gencode("EQ", $2, VALUE, expr_false, VALUE, label1_idx, VALUE);
    $2 = label1_idx;
  }
  THEN statement {
    int label2_idx = new_label();
    gencode("jump", -1, VALUE, -1, VALUE, label2_idx, VALUE);
    gencode("label", -1, VALUE, -1, VALUE, $2, VALUE);
    $5 = label2_idx;
  }
  ELSE statement {
    gencode("label", -1, VALUE, -1, VALUE, $5, VALUE);
  }
  | WHILE {
    int label_loop_stop = new_label();
    int label_loop_start = new_label();
    gencode("label", -1, VALUE, -1, VALUE, label_loop_start, VALUE);
    $1 = label_loop_start; //lab2 (start)
    $$ = label_loop_stop;  //lab1 (stop), $$ odnosi się do atrybutu bloku akcji, w całej produkcji $2
  }
  expression DO {
    int expr_false = new_num("0", INTEGER);
    gencode("EQ", $3, VALUE, expr_false, VALUE, $2, VALUE); //lab1 (stop)
  }
  statement {
    gencode("jump", -1, VALUE, -1, VALUE, $1, VALUE); //lab2 (start)
    gencode("label", -1, VALUE, -1, VALUE, $2, VALUE); //lab1 (stop)
  }
  ;

variable:
  ID {
    $$ = $1;
  }
  | ID '[' simple_expression ']' {  //default 'expression' found in provided grammar makes no sense to me(?) why would relop be relevant?
    if(symtable[$3].type == REAL) {
      int tmp_idx = new_temp(INTEGER);
      gencode("realtoint", $3, VALUE, -1, VALUE, tmp_idx, VALUE);
      $3 = tmp_idx;
    }

    int start_idx = find_num(symtable[$1].array_info.start_idx);
    int tmp1_idx = new_temp(INTEGER);
    gencode("-", $3, VALUE, start_idx, VALUE, tmp1_idx, VALUE);
    int element_size;
    if(symtable[$1].type == INTEGER) {
      element_size = new_num("4", INTEGER);
    } 
    else if(symtable[$1].type == REAL) {
      element_size = new_num("8", INTEGER);
    }
    gencode("*", tmp1_idx, VALUE, element_size, VALUE, tmp1_idx, VALUE);
    int address_element_in_array = new_temp(INTEGER);
    gencode("+", $1, ADDRESS, tmp1_idx, VALUE, address_element_in_array, VALUE);

    symtable[address_element_in_array].is_reference = true;
    $$ = address_element_in_array;
  }
  ;

procedure_statement:
  ID
  | ID '(' expression_list ')' {
    if($1 == WRITE) {
      for(auto symTabIdx : ids_list) {
        gencode("write", -1, VALUE, -1, VALUE, symTabIdx, VALUE);
      }
    }
    else if($1 == READ) {
      for(auto symTabIdx : ids_list) {
        gencode("read", -1, VALUE, -1, VALUE, symTabIdx, VALUE);
      }
    }
    ids_list.clear();
  }
  ;

expression_list:
  expression {
    ids_list.push_back($1);
  }
  | expression_list ',' expression {
    ids_list.push_back($3);
  }
  ;

expression:
  simple_expression
  | simple_expression RELOP simple_expression {
    int label_true = new_label();
    gencode(translate_tokens_to_operations($2), $1, VALUE, $3, VALUE, label_true, VALUE);
    int relop_result = new_temp(INTEGER);
    int relop_false = new_num("0", INTEGER);
    gencode("assign", relop_false, VALUE, -1, VALUE, relop_result, VALUE);
    int label_finally = new_label();
    gencode("jump", -1, VALUE, -1, VALUE, label_finally, VALUE);
    gencode("label", -1, VALUE, -1, VALUE, label_true, VALUE);
    int relop_true = new_num("1", INTEGER);
    gencode("assign", relop_true, VALUE, -1, VALUE, relop_result, VALUE);
    gencode("label", -1, VALUE, -1, VALUE, label_finally, VALUE);
    $$ = relop_result;
  }
  ;

simple_expression:
  term
  | ADDOP term {
    if ($1 == SUB) {
      int zero = new_num("0", symtable[$2].type);
      $$ = new_temp(symtable[$2].type);
      gencode("-", zero, VALUE, $2, VALUE, $$, VALUE);
    } else {
      $$ = $2;
    }
  }
  | simple_expression ADDOP term {
    $$ = new_temp(get_result_type($1, $3));
    gencode(translate_tokens_to_operations($2), $1, VALUE, $3, VALUE, $$, VALUE);
  }
  | simple_expression OR term {
    $$ = new_temp(get_result_type($1, $3));
    gencode("or", $1, VALUE, $3, VALUE, $$, VALUE);
  }
  ;
        
term:
  factor
  | term MULOP factor {
    $$ = new_temp(get_result_type($1, $3));
    gencode(translate_tokens_to_operations($2), $1, VALUE, $3, VALUE, $$, VALUE);
  }
  ;

factor:
  variable
  | ID '(' expression_list ')'
  | NUM {
    $$ = $1;
  }
  | '(' expression ')' {
    $$ = $2;
  }
  | NOT factor {
    int label_equal_zero = new_label();
    int zero = new_num("0", INTEGER);
    int label_not_equal_zero = new_label();
    int one = new_num("1", INTEGER);
    gencode("EQ", $2, VALUE, zero, VALUE, label_equal_zero, VALUE);

    int tmp_1 = new_temp(INTEGER);
    gencode("assign", zero, VALUE, -1, VALUE, tmp_1, VALUE);
    gencode("jump", -1, VALUE, -1, VALUE, label_not_equal_zero, VALUE);
    
    gencode("label", -1, VALUE, -1, VALUE, label_equal_zero, VALUE);
    gencode("assign", one, VALUE, -1, VALUE, tmp_1, VALUE);
    gencode("label", -1, VALUE, -1, VALUE, label_not_equal_zero, VALUE);
    $$ = tmp_1;
  }
  ;
%%

void parse() {
  yyparse();
}

void yyerror(char const *s) {
  fprintf(stderr, "%s, in line %d\n", s, lineno);
  print_symtable();
  yylex_destroy();
  return;
}

const char *token_name(int token) {
  return yytname[YYTRANSLATE(token)];
}
