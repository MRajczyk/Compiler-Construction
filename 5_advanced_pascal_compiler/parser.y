%{
#include "global.hpp"

std::vector<int> ids_list;
array_info_t array_info;
int array_type;

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

%token EQ
%token GE
%token LE
%token NE
%token GT
%token LT

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
        sym->address = get_address(sym->name);
      }
      else if ($5 == ARRAY) {
        symbol_t* sym = &symtable[symTabIdx];
        sym->token = $5;
        sym->type = array_type;
        sym->address = get_address(sym->name);
        sym->array_info = array_info;
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
    array_type = $9;
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
  subprogram_head declarations compound_statement
  ;

subprogram_head:
  FUNCTION ID arguments ':' standard_type ';'
  | PROCEDURE ID arguments ';'
  ;

arguments:
  '(' parameter_list ')'
  | %empty
  ;

parameter_list:     
  identifier_list ':' type
  | parameter_list ';' identifier_list ':' type
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
    
  }
  THEN statement {
  
  }
  ELSE statement {

  }
  | WHILE expression {

  }
  DO statement {

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
    gencode("+", $1, VALUE, tmp1_idx, VALUE, address_element_in_array, VALUE);

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
  | simple_expression OR term
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
  | NOT factor
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
