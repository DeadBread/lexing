%{
#define YYSTYPE char*
	
#include <stdio.h>
#include "trynext.tab.h"

void yyerror(char *s);

%}

%option yylineno
%option noyywrap

%%

[-]			return DEF;
[>]			{fprintf(stderr,"right!\n"); return RIGHT;}
[<]			{fprintf(stderr,"left!\n"); return LEFT;}
[(]			return LEFTBRACE;
[)]			return RIGHTBRACE;
[*]			{fprintf(stderr,"star\n");return STAR;}
[!]			return SIGN;

[cC][rR][eE][aA][tT][eE]		{fprintf(stderr,"create\n"); return CREATE;}
[mM][aA][kK][eE]				{printf ("make!\n"); return MAKE;}
[aA][dD][dD]					return ADD;
[aA][dD][dD][aA][lL][lL]		return ADDALL;
[cC][oO][pP][yY]				{printf("copy\n"); return COPY;}
[pP][rR][[iI][nN][tT][iI][nN][fF][oO]	return PRINTINFO;
[hH][eE][aA][dD][eE][rR]				{printf("FUCKINGHEADER\n"); return HEADER;}
[cC][oO][mM][pP][aA][rR][eE]			return COMPARE;
[sS][oO][rR][tT]						return SORT;
[tT][yY][pP][eE][sS][oO][rR][tT]		return TYPESORT;
[eE][xX][iI][tT]						return EXIT;

[a-zA-Z/.][a-zA-Z0-9/.]*	{fprintf(stderr,"word\n"); yylval=strdup(yytext); return WORD;}
[0-9]+						{yylval=strdup(yytext); return NUMBER;}

[ \n]
%%
