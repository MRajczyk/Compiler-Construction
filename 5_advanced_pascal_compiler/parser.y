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
    output_code("jump.i\t#lab0", "jump.i lab0", true);
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
    if(symtable.at($1).token != VAR) {
      fprintf(stderr, "Error, Attempted write to an undeclared variable: %s, in line %d\n", symtable.at($1).name.c_str(), lineno - 1);
      yylex_destroy();
      return -1;
    }
    gencode("assign", $3, VALUE, -1, VALUE, $1, VALUE);
  }
  | procedure_statement
  | compound_statement
  | IF expression THEN statement ELSE statement
  | WHILE expression DO statement
  | WRITE '(' ID ')' {
    gencode("write", -1, VALUE, -1, VALUE, $3, VALUE);
  }
  | READ '(' ID ')' {
    gencode("read", -1, VALUE, -1, VALUE, $3, VALUE);
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
