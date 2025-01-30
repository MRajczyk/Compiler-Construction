%option noyywrap
%{
#include "global.hpp"

int lineno = 1;
%}

ws 					        [ \t]+
letter              [a-zA-Z]
digit               [0-9]
id                  {letter}({letter}|{digit})*
integer             {digit}+
real                {integer}(\.{integer})?
relop				        "<"|">"|"<="|">="|"=="|"<>"
addop               "+"|"-"
mulop               "*"|"/"|"div"|"mod"|"and"|"%"

%%

"\r"              {};
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
                    yylval = get_operation_token(yytext);
				            return ADDOP;
				          }
{mulop}			      {
                    yylval = get_operation_token(yytext);
                    return MULOP;
                  }
"procedure"		    return PROCEDURE;
"function"		    return FUNCTION;
{id}		          {
                    yylval = insert(yytext, ID, NONE);
                    return ID;
			            }	
{integer}         {
                    yylval = insert(yytext, NUM, INTEGER);
                    return NUM;
                  }
{real}            {
                    yylval = insert(yytext, NUM, REAL);
                    return NUM;
				          }
.                 {
                    return yytext[0];
                  }			
<<EOF>>             return DONE;	
%%
