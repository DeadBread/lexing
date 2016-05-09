%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <unistd.h>
	#include <iostream>
	#include <fstream>

    using namespace std;

    extern int yylineno;
    extern int yyparse();
    extern int yylex();

    extern FILE *yyin;
    void yyerror(const char *s)
    {
        std::cerr << s << ", line " << yylineno << std::endl;
        exit(1);
    }

    int main()
    {
    	yyparse();
    }

	#define YYSTYPE char *
%}



%token DEF RIGHT LEFT LEFTBRACE RIGHTBRACE STAR SIGN 
%token WORD NUMBER
%token CREATE MAKE ADD ADDALL COPY PRINTINFO HEADER TYPESORT EXIT SORT COMPARE

%%
EVALUATE: commands

commands: 
    command | commands command 
    ;

command:
	create
	| make
	| add
	| header {cout << "in HEADER" << endl;}
	| compare
	| sort
	| printinfo
	| copy {cout << "in copy" << endl;}
	;

path:	
	LEFT WORD RIGHT
		{
			$$ = $2;
		}
	;

star:
	STAR 
	{
		cout << "TO BE!" << endl;
	}


filename:
	star WORD star
		{
			printf("in filename\n");
			$$ = $2;			
		}
	;


create:
	CREATE path filename
	{
		char* fname = new char(255);
		fname = strcat($2,$3);
		std::ofstream creator(fname);
		if (!creator) {std::cerr << "error opening file!" << endl;}
		delete(fname);
	}
	;

make: 
	MAKE path path filename
	{
		char* myname = new char[255];
		myname = strcat($4,".m3u");
		if (fork()) {
			wait();
			cout << "creation complete" << endl;
		}
		else {
			execlp("/home/kardamon/Documents/scripts/m3uer.sh", "m3uer.sh", $2, $3, ">", myname, NULL);
		}
		delete (myname);
	}
	| 
	MAKE path filename
	{
		char* myname = new char[255];
		strcat($3,".m3u");
		if (fork()) {
			wait();
			cout << "creation complete" << endl;
		}
		else {
			execlp("/home/kardamon/Documents/scripts/m3uer.sh", "m3uer.sh", $2, $2, ">", myname, NULL);
		}
		delete(myname);
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
			execlp("cp", "cp", $2, $3, NULL);
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
			execlp("cp", "cp",  $2, $3, NULL);
		}
	}
	;

printinfo: 
	PRINTINFO filename
	{
		cout << "yet too hard :(" << endl;
	}
	;

hs:
	HEADER
	{
		printf("not to be!\n");
	}

header:
	hs WORD
	{
		cout <<"how the fuck did I get here?" << endl;
		printf("%s", $2);
		cout << "word is " << $2 << "finish" << endl;
		cout << "is it&" << endl;
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
			execlp("cmp", "smp" , $2, $3, NULL);
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
			execlp("sort", "sort" , $2, NULL);
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
			execlp("sort", "sort", $2, ">", "$4", NULL);
		}
	}
	;

%%






