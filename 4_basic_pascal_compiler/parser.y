%{
#include "global.hpp"

std::vector<int> ids_list;

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
    output_code("jump.i\t#lab0", "jump.i lab0");
  }
  '(' identifier_list ')' ';' {
    for(auto &symTabIdx : ids_list) {
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
    output_code("exit\t", "exit");
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
    // dodać sprawdzanie typów czy jest INTEGER albo REAL
    for(auto &symTabIdx : ids_list) {
      symbol_t* sym = &symtable[symTabIdx];
      sym->token = VAR;
      sym->type = $5;
      sym->address = get_address(sym->name);
    }
    ids_list.clear();
  }
  | %empty
  ;

type:               
  standard_type
  | ARRAY '[' NUM '.' '.' NUM ']' OF standard_type
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
    std::string first_var = "";
    if (symtable.at($3).token == VAR) {
      first_var = std::to_string(symtable.at($3).address);
      output_code("mov.i\t" + first_var + ", " + std::to_string(symtable.at($1).address), "mov.i\t" + symtable.at($3).name + ", " + symtable.at($1).name);
    } else {
      first_var = symtable.at($3).name;
      output_code("mov.i\t" + std::string("#") + first_var + ", " + std::to_string(symtable.at($1).address), "mov.i\t" + first_var + ", " + symtable.at($1).name);
    }
  }
  | procedure_statement
  | compound_statement
  | IF expression THEN statement ELSE statement
  | WHILE expression DO statement
  | WRITE '(' ID ')' {
    output_code("write.i\t" + std::to_string(symtable.at($3).address), "\twrite.i\t" + symtable.at($3).name);
  }
  | READ '(' ID ')' {
    output_code("read.i\t" + std::to_string(symtable.at($3).address), "\read.i\t" + symtable.at($3).name);
  }
  ;

variable:
  ID {
    $$ = $1;
  }
  | ID '[' expression ']'
  ;

procedure_statement:
  ID
  | ID '(' expression_list ')'
  ;

expression_list:
  expression
  | expression_list ',' expression
  ;

expression:
  simple_expression
  | simple_expression RELOP simple_expression
  ;

simple_expression:
  term
  | SIGN term {
    if ($1 == SUB) {
      int zero = new_num("0", symtable[$2].type);
      int temp_pos = new_temp(INTEGER);
      gencode("-", zero, ADDRESS, $2, ADDRESS, temp_pos, ADDRESS);
      $$ = temp_pos;
    } else {
      $$ = $2;
    }
  }
  | simple_expression ADDOP term {
    int temp_variable_pos = new_temp(INTEGER);
    gencode(translate_tokens_to_operations($2), $1, ADDRESS, $3, ADDRESS, temp_variable_pos, ADDRESS);
    $$ = temp_variable_pos;
  }
  | simple_expression OR term
  ;
        
term:
  factor
  | term MULOP factor {
    int temp_variable_pos = new_temp(INTEGER);
    gencode(translate_tokens_to_operations($2), $1, ADDRESS, $3, ADDRESS, temp_variable_pos, ADDRESS);
    $$ = temp_variable_pos;
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
  void print_symtable();
  yylex_destroy();
}

const char *token_name(int token) {
  return yytname[YYTRANSLATE(token)];
}
