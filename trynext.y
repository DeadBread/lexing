%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <iostream>
#include <fstream>


#define YYPRINT(file, type, value) yyprint(file,type,value)
#define YYSTYPE char *

using namespace std;
 
extern "C"
{
		int yyparse(void);       
        int yywrap()
        {
            return 1;
        }
        int yylex() { return getc(stdin); };

        static void yyprint(FILE *file, int type, YYSTYPE value)
		{
			printf(" %s", value);
		}
}

void yyerror(const char *str)
{
        fprintf(stderr,"ошибка: %s\n",str);
}
  
%}

%token DOT SLASH DEF RIGHT LEFT LEFTBRACE RIGHTBRACE STAR SIGN 
%token WORD NUMBER
%token CREATE MAKE ADD ADDALL COPY PRINTINFO HEADER TYPESORT EXIT SORT COMPARE

%%

EVALUATE : commands 

commands: 
    command | commands command  
    ;

command:
	| create 
	| make 
	| add  
	| header 
	| compare  
	| sort  
	| printinfo  
	| copy
	;

path:
	WORD				{$$ = $1;}
	| WORD SLASH path	{$$ = strcat($1,strcat($2,$3));}
	;

filename:
	path DOT WORD		
	{
		$$ = strcat($1,strcat($2,$3));
	}
	;

	//так ведь можно? 

create:
	CREATE path filename
	{
		char* fname = strcat($2,$3);
		std::ofstream creator(fname);
		if (!creator) {std::cerr << "error opening file!" << endl;}
	}

make: 
	MAKE path path filename
	{
		char* myname = strcat($4,".m3u");
		if (fork()) {
			wait();
			cout << "creation complete" << endl;
		}
		else {
			int ign = execlp("/home/kardamon/Documents/scripts/m3uer.sh", "m3uer.sh", $2, $3, ">", myname, NULL);
		}
	}
	| 
	MAKE path filename
	{
		char* myname = strcat($3,".m3u");
		if (fork()) {
			wait();
			cout << "creation complete" << endl;
		}
		else {
			int ign = execlp("/home/kardamon/Documents/scripts/m3uer.sh", "m3uer.sh", $2, $2, ">", myname, NULL);
		}
	}
	;

add:
	ADD filename filename //where, what
	{
		std::ofstream adder($2, std::fstream::app);
		adder << $3 << endl;
	}
	;

copy: 
	COPY filename path
	{
		if (fork())
		{
			wait();
		}
		else
		{
			int ign = execlp("cp", "cp", $2, $3, NULL);
		}
	}
	|
	COPY filename filename
	{
		if (fork())
		{
			wait();
		}
		else
		{
			int ign = execlp("cp", "cp",  $2, $3, NULL);
		}
	}
	;

printinfo:
	PRINTINFO filename
	{
		cout << "yet too hard :(" << endl;
	}
	;

header:
	HEADER WORD
	{
		cout <<"not sure I'll do it :C" << endl;
	}
	;

compare:
	COMPARE filename filename
	{
		if (fork())
		{
			wait();
		}
		else
		{
			int ign = execlp("cmp", "smp" , $2, $3, NULL);
		}
	}
	;

sort:
	SORT filename
	{

		if (fork())
		{
			wait();
		}
		else
		{
			int ign = execlp("sort", "sort" , $2, NULL);
		}
	}
	|
	SORT filename SIGN filename
	{

		if (fork())
		{
			wait();
		}
		else
		{
			int ign = execlp("sort", "sort", $2, ">", "$4", NULL);
		}
	}
	;

%%






