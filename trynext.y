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

    struct Current_state
    {
    	char* file;
    	char* path;

    	Current_state()
    	{
    		file = new char(255);
    		path = new char(255);
    	}

    	~Current_state()
    	{
    		delete(file);
    		delete(path);
    		cout << "deleting current here" << endl;
    	}

    	void printstates()
    	{
    		cout << path << endl << file << endl;
    	}
    };

    Current_state cur;

	#define YYSTYPE char *
%}

%token DEF RIGHTBR LEFTBR LEFTBRACE RIGHTBRACE SIGN QSIGN STAR
%token WORD NUMBER
%token CREATE MAKE ADD ADDALL COPY PRINTINFO HEADER TYPESORT EXIT SORT COMPARE GOTO RENAME

%%
EVALUATE: commands {get_current_dir_name();} ;

commands: 
    command | commands command 
    ;

command:
	  goto
	| new_cur
	| printcur
	| create
	| make
	| add
	| header 
	| compare
	| sort
	| printinfo
	| copy 
	| rename
	;

path:	
	LEFTBR WORD RIGHTBR		
		{
			$$=$2;
		}
	;

filename:
	STAR WORD STAR
		{
			$$=$2;
		}
	;

goto:
	GOTO path
		{
			cur.path = strdup($2);
		}
	;

new_cur:
	SIGN filename
		{
			cur.file = strdup($2);
		}
	;

printcur:
	QSIGN
		{
			cout << "current directory and file" << endl;
			cur.printstates();
		}

	;

create:
	CREATE filename
	{
		char* fname = new char(255);
		fname = strcat(cur.path,$2);
		std::ofstream creator(fname);
		if (!creator) {std::cerr << "error opening file!" << endl;}
		creator.close();
		cout << "Creation complete!" << endl;
	}
	;

make: 
	MAKE path filename
	{
		if (fork()) {
			wait();
			cout << "creation complete" << endl;
		}
		else {
			execlp("/home/kardamon/Documents/scripts/m3uer.sh", "m3uer.sh", cur.path, $2, ">", $3, NULL);
		}
	}
	| 
	MAKE filename
	{
		if (fork()) {
			wait();
			cout << "creation complete" << endl;
		}
		else {
			execlp("/home/kardamon/Documents/scripts/m3uer.sh", "m3uer.sh", cur.path, cur.path, ">", $2, NULL);
		}
	}
	;

add:
	ADD filename	//надо изменить, ибо filename - не универсален
	{
		std::ofstream adder(cur.file, std::fstream::app);
		cout << $2 << endl;
		adder.close();
	}
	;

copy: 
	COPY path
	{
		if (fork())
		{
			wait();
		}
		else
		{
			execlp("rcp", "rcp", "-r", cur.file, $2, NULL);
		}
	}
	|
	COPY filename
	{
		if (fork())
		{
			wait();
		}
		else
		{
			execlp("rcp", "rcp",  cur.file, $2, NULL);
		}
	}
	;

printinfo: 
	PRINTINFO
	{
		cout << "yet too hard :(" << endl;
	}
	;

header:
	HEADER WORD
	{
		cout <<"to be deleted" << endl;
	}
	;

compare:
	COMPARE filename
	{
		if (fork())
		{
			wait();
		}
		else
		{
			execlp("cmp", "cmp" , cur.file, $2, NULL);
		}
	}
	;

sort:
	SORT
	{
		if (fork())
		{
			wait();
		}
		else
		{
			execlp("sort", "sort" , cur.file, NULL);
		}
	}
	|
	SORT DEF RIGHTBR filename
	{

		if (fork())
		{
			wait();
		}
		else
		{
			execlp("sort", "sort", cur.file, ">", "$4", NULL);
		}
	}
	;

rename:
	RENAME filename
	{
		if (rename(cur.file, $2)) printf("it goes wrong");
		cur.file = $2;
		cout << "new name is" << $2 << endl;
	}
	;

%%






