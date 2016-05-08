%{
#define YYSTYPE char*
	
#include <stdio.h>
#include "trynext.tab.h"

void yyerror(char *s);

%}

%option yylineno
%option noyywrap

%%

[.]			return DOT;
[/]			return SLASH;
[-]			return DEF;
[>]			return RIGHT;
[<]			return LEFT;
[(]			return LEFTBRACE;
[)]			return RIGHTBRACE;
[*]			return STAR;
[!]			return SIGN;

[cC][rR][eE][aA][tT][eE]		return CREATE;
[mM][aA][kK][eE]				return MAKE;
[aA][dD][dD]					return ADD;
[aA][dD][dD][aA][lL][lL]		return ADDALL;
[cC][oO][pP][yY]				return COPY;
[pP][rR][[iI][nN][iI][nN][fF][oO]	return PRINTINFO;
[hH][eE][aA][dD][eE][rR]			return HEADER;
[cC][oO][mM][pP][aA][rR][eE]		return COMPARE;
[sS][oO][rR][tT]					return SORT;
[tT][yY][pP][eE][sS][oO][rR][tT]	return TYPESORT;
[eE][xX][iI][tT]					return EXIT;

[a-zA-Z][a-zA-Z0-9]*	yylval=strdup(yytext); return WORD;
[0-9]+					yylval=strdup(yytext); return NUMBER;

[ \n]
%%
