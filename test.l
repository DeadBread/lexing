%{
#define YYSTYPE char *
#include "test.tab.h"
%}

%option yylineno
%option noyywrap

%%

#include { yylval = strdup(yytext) ; return INCLUDE;}
#create  { yylval = strdup(yytext) ; return CREATE;}

[ \t\r\n]+ ; // whitespace

. { return *yytext; }

%%