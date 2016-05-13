%{
#define YYSTYPE char*
	
#include <stdio.h>
#include "trynext.tab.h"

void yyerror(char *s);

%}

%option yylineno
%option noyywrap

%x STR

%%
[-]			return DEF;
[>]			return RIGHTBR;
[<]			return LEFTBR;
[(]			return LEFTBRACE;
[)]			return RIGHTBRACE;
[*]			return STAR;
[!]			return SIGN;
[?]			return QSIGN;
[+]			return PLUS;
[=]			return EQUALS;


[cC][rR][eE][aA][tT][eE]				return CREATE;
[mM][aA][kK][eE]						return MAKE;
[aA][dD][dD][aA][lL][lL]				return ADDALL;
[cC][oO][pP][yY]						return COPY;
[gG][oO][tT][oO]						return GOTO;
[aA][dD][dD]							return ADD;
[pP][rR][[iI][nN][tT][iI][nN][fF][oO]	return PRINTINFO;
[hH][eE][aA][dD][eE][rR]				return HEADER;
[cC][oO][mM][pP][aA][rR][eE]			return COMPARE;
[sS][oO][rR][tT]						return SORT;
[tT][yY][pP][eE][sS][oO][rR][tT]		return TYPESORT;
[rR][eE][nN][aA][mM][eE]				return RENAME;
[eE][xX][iI][tT]						return EXIT;
[lL][iI][sS][tT]						return LST;
[dD][iI][rR]							return DIR;
[pP][rR][iI][nN][tT]					return PRINT;
[eE][nN][dD]							return END;


[a-zA-Z.\/~][a-zA-Z0-9.\/]*		yylval=strdup(yytext); return WORD;
[0-9]+							yylval=strdup(yytext); return NUMBER;
[ \n]

["]             { yylval = strdup(""); BEGIN(STR); }
<STR>[^\\\n"]+  yylval = strcat(yylval, yytext);
<STR>\\n        yylval = strcat(yylval, "\n");
<STR>\\["]      yylval = strcat(yylval,"\"");
<STR>["]        { BEGIN(INITIAL); return STRING; }

%%
