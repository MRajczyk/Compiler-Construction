%option noyywrap
%{
#include "global.hpp"

int lineno = 1;
%}

ws 					        [ \t]+
letter              [a-zA-Z]
digit               [0-9]
id                  {letter}({letter}|{digit})*
digits				      {digit}+
optional_digit  	  {digits}(.{digits})?
optional_exponent	  ([Ee][+-]?{digits})?
num					        {digits}{optional_fraction}{optional_exponent}
relop				        "<"|">"|"<="|">="|"=="|"<>"
addop               "+"|"-"
mulop               "*"|"/"|"div"|"mod"|"and"

%%

{ws}			        {};											
"\n"			        lineno++;
"program"		      return PROGRAM;
"var"			        return VAR;
"integer" 	      return INTEGER;
"real" 			      return REAL;
"array"			      return ARRAY;
"of"			        return OF;
"then"			      return THEN;
"if"			        return IF;
"while"			      return WHILE;
"do"			        return DO;
"else"			      return ELSE;
"begin"			      return BEGIN_TOKEN;
"end"			        return END_TOKEN;
":="			        return ASSIGNOP;
"or" 			        return OR;
"write"			      return WRITE;
"read"			      return READ;
{relop}			      {
                    return RELOP;
                  }
{addop}			      {
				            return ADDOP;
				          }
{mulop}			      {
                    return MULOP;
                  }
"procedure"		    return PROCEDURE;
"function"		    return FUNCTION;
{id}		          {
                    return ID;
			            }	
{digits}          {
                  }
{optional_digit}  {
				          }
<<EOF>>           return DONE;
.                 {
                    return yytext[0];
                  }				
%%
