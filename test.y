	
%{

#include <stdio.h>
void yyerror(char *s) {
fprintf (stderr, "fucking fuckity fuck %s\n", s);
}
%}

%token INCLUDE CREATE

%%

EVALUATE: RULE { printf("%s" , yylval);}

PREPROC: INCLUDE 
;

RULE : CREATE {printf("yeah!");}
;

%%