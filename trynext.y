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

<<<<<<< HEAD
<<<<<<< HEAD


%token DEF RIGHT LEFT LEFTBRACE RIGHTBRACE STAR SIGN 
=======
%token DEF RIGHTBR LEFTBR LEFTBRACE RIGHTBRACE SIGN STAR
>>>>>>> 9c7cb09... fucked-up Makefile bug fixed. Great changes are to come
=======
%token DEF RIGHTBR LEFTBR LEFTBRACE RIGHTBRACE SIGN QSIGN STAR
>>>>>>> d720383... mostly working. Have to debug minor bugs and add some extra features. Already consists working *cur* structure
%token WORD NUMBER
%token CREATE MAKE ADD ADDALL COPY PRINTINFO HEADER TYPESORT EXIT SORT COMPARE GOTO RENAME

%%
<<<<<<< HEAD
<<<<<<< HEAD
EVALUATE: commands
=======
EVALUATE: commands {printf("here!\n");} ;
>>>>>>> 9c7cb09... fucked-up Makefile bug fixed. Great changes are to come
=======
EVALUATE: commands {getwd(cur.path);} ;
>>>>>>> d720383... mostly working. Have to debug minor bugs and add some extra features. Already consists working *cur* structure

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
	| header {cout << "in HEADER" << endl;}
	| compare
	| sort
	| printinfo
<<<<<<< HEAD
	| copy {cout << "in copy" << endl;}
=======
	| copy
	| rename
>>>>>>> d720383... mostly working. Have to debug minor bugs and add some extra features. Already consists working *cur* structure
	;

path:	
<<<<<<< HEAD
	LEFT WORD RIGHT
		{
			$$ = $2;
=======
	LEFTBR WORD RIGHTBR		
		{
			$$=$2;
>>>>>>> 9c7cb09... fucked-up Makefile bug fixed. Great changes are to come
		}
	;

star:
	STAR 
	{
		cout << "TO BE!" << endl;
	}


filename:
<<<<<<< HEAD
	star WORD star
		{
			printf("in filename\n");
			$$ = $2;			
		}
	;

=======
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
<<<<<<< HEAD
>>>>>>> 9c7cb09... fucked-up Makefile bug fixed. Great changes are to come
=======
	;
>>>>>>> d720383... mostly working. Have to debug minor bugs and add some extra features. Already consists working *cur* structure

create:
	CREATE filename
	{
		char* fname = new char(255);
		fname = strcat(cur.path,$2);
		std::ofstream creator(fname);
		if (!creator) {std::cerr << "error opening file!" << endl;}
		cout << "Creation complete!" << endl;
	}
	;

make: 
	MAKE path filename
	{
<<<<<<< HEAD
		char* myname = new char[255];
		myname = strcat($4,".m3u");
=======
>>>>>>> d720383... mostly working. Have to debug minor bugs and add some extra features. Already consists working *cur* structure
		if (fork()) {
			wait();
			cout << "creation complete" << endl;
		}
		else {
			execlp("/home/kardamon/Documents/scripts/m3uer.sh", "m3uer.sh", cur.path, $2, ">", $3, NULL);
		}
		delete (myname);
	}
	| 
	MAKE filename
	{
<<<<<<< HEAD
		char* myname = new char[255];
		strcat($3,".m3u");
=======
		char* myname = strcat($2,".m3u");
>>>>>>> d720383... mostly working. Have to debug minor bugs and add some extra features. Already consists working *cur* structure
		if (fork()) {
			wait();
			cout << "creation complete" << endl;
		}
		else {
			execlp("/home/kardamon/Documents/scripts/m3uer.sh", "m3uer.sh", cur.path, cur.path, ">", myname, NULL);
		}
		delete(myname);
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






