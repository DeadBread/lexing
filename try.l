%{
#define YYSTYPE char*
	
#include <stdio.h>
#include "trynext.tab.h"

void yyerror(char *s);

%}

%option yylineno
%option noyywrap

%%

<<<<<<< HEAD
[-]			return DEF;
[>]			{fprintf(stderr,"right!\n"); return RIGHT;}
[<]			{fprintf(stderr,"left!\n"); return LEFT;}
=======

[-]			return DEF;
[>]			return RIGHTBR;
[<]			return LEFTBR;
>>>>>>> 9c7cb09... fucked-up Makefile bug fixed. Great changes are to come
[(]			return LEFTBRACE;
[)]			return RIGHTBRACE;
[*]			{fprintf(stderr,"star\n");return STAR;}
[!]			return SIGN;

<<<<<<< HEAD
[cC][rR][eE][aA][tT][eE]		{fprintf(stderr,"create\n"); return CREATE;}
[mM][aA][kK][eE]				{printf ("make!\n"); return MAKE;}
[aA][dD][dD]					return ADD;
[aA][dD][dD][aA][lL][lL]		return ADDALL;
[cC][oO][pP][yY]				{printf("copy\n"); return COPY;}
=======
[cC][rR][eE][aA][tT][eE]				return CREATE;
[mM][aA][kK][eE]						return MAKE;
[aA][dD][dD]							return ADD;
[aA][dD][dD][aA][lL][lL]				return ADDALL;
[cC][oO][pP][yY]						return COPY;
>>>>>>> 9c7cb09... fucked-up Makefile bug fixed. Great changes are to come
[pP][rR][[iI][nN][tT][iI][nN][fF][oO]	return PRINTINFO;
[hH][eE][aA][dD][eE][rR]				{printf("FUCKINGHEADER\n"); return HEADER;}
[cC][oO][mM][pP][aA][rR][eE]			return COMPARE;
[sS][oO][rR][tT]						return SORT;
[tT][yY][pP][eE][sS][oO][rR][tT]		return TYPESORT;
[eE][xX][iI][tT]						return EXIT;

<<<<<<< HEAD
[a-zA-Z/.][a-zA-Z0-9/.]*	{fprintf(stderr,"word\n"); yylval=strdup(yytext); return WORD;}
[0-9]+						{yylval=strdup(yytext); return NUMBER;}
=======
[a-zA-Z.\/~][a-zA-Z0-9.\/]*	printf("word %s\n", yytext); yylval=strdup(yytext); return WORD;
[0-9]+							yylval=strdup(yytext); return NUMBER;
>>>>>>> 9c7cb09... fucked-up Makefile bug fixed. Great changes are to come

[ \n]
%%
