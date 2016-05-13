%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <unistd.h>
	#include <iostream>
	#include <fstream>
	#include <sys/types.h>
	#include <sys/stat.h>
	#include <fcntl.h>

    using namespace std;

    extern int yylineno;
    extern int yyparse();
    extern int yylex();

    extern FILE *yyin;
    void yyerror(const char *s)
    {
        std::cerr << s << ", line " << yylineno << std::endl;
        yyparse();
        //exit(1);
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
    		path = get_current_dir_name();
    	}

    	~Current_state()
    	{
    		delete(file);
    		delete(path);
    	}

    	void printstates()
    	{
    		cout << path << endl << file << endl;
    	}
    };

    Current_state cur;

	#define YYSTYPE char *
%}

%token DEF RIGHTBR LEFTBR LEFTBRACE RIGHTBRACE SIGN QSIGN STAR PLUS EQUALS
%token WORD NUMBER
%token CREATE MAKE ADD ADDALL COPY PRINTINFO HEADER TYPESORT EXIT SORT COMPARE GOTO RENAME LST DIR

%%

evaluate: 
	commands

commands: 
      command
    | commands command 
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
	| list
	| dir
	| concat
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
	|
	GOTO PLUS path
		{
			cur.path = strcat(cur.path, "/");
			cur.path = strcat(cur.path, $3);
		}

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
		fname = strcpy(fname, cur.path);
		fname = strcat(fname, "/");
		fname = strcat(fname,$2);
		
		int fd = open(fname,O_RDONLY | O_CREAT | O_TRUNC,0666);

		if (fd < 0) 
			{
				std::cerr << "error opening file!" << endl;
			}
		else
		{
			cur.file = $2;
			cout << "Creation complete!" << endl;
		}

		close (fd);
	}
	;

make: 
	MAKE path filename
	{
		char* fname = new char[255];
		fname = strcpy(fname, cur.path);
		fname = strcat(strcat(fname, "/"), $3);

		int fd = open(fname, O_WRONLY | O_CREAT | O_TRUNC,0666);

		if (fork()) {
			wait();
			cout << "creation complete" << endl;
		}
		else {
			dup2(fd, 1);
			execlp("/home/kardamon/Documents/scripts/m3uer.sh", "m3uer.sh", cur.path, $2, NULL);
		}

		delete(fname);
		close (fd);

		cur.file = $3;
	}
	| 
	MAKE filename
	{

		char* fname = new char[255];
		fname = strcpy(fname, cur.path);
		fname = strcat(strcat(fname, "/"), $2);
		int fd = open(fname ,O_WRONLY | O_CREAT,0666);

		if (fork()) {
			wait();
			cout << "creation complete" << endl;
		}
		else {

			dup2(fd, 1);
			execlp("/home/kardamon/Documents/scripts/m3uer.sh", "m3uer.h", cur.path, " " , ">", $2, NULL);
		}

		delete(fname);
		close (fd);

		cur.file = $2;
	}
	;

add:
	ADD filename	//надо изменить, ибо filename - не универсален
	{
		//
		char* tmp = new char[255];
		tmp = strdup(cur.path);
		strcat(tmp, "/");
		strcat(tmp, cur.file);

		int fd = open(tmp, O_CREAT | O_WRONLY | O_APPEND, 0666);
		cout << tmp << endl;
		if (fd < 0) 
		{	
			cout << "error opening file" << endl;	
		}
		else
		{
			char* myfname = new char[255];
			myfname = strdup($1);
			strcat (myfname, "\n");
			write(fd, myfname, strlen(myfname));
		}

		close(fd);
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
			execlp("sort", "sort" , cur.file, ">", cur.file,  NULL);
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

list:
	LST
		{
			if (fork())
			{
				wait();
			}
			else
			{
				execlp("/home/kardamon/Documents/scripts/lister.sh", "lister.sh", cur.path, NULL);
			}
		}
	;

dir:
	DIR
		{
			if (fork())
			{
				wait();
			}
			else
			{
				execlp("ls", "ls", cur.path, "-d", "*/" ,NULL);
			}
		}
	;

concat:
	PLUS EQUALS filename
		{
			char* tmp = new char[255];
			tmp = strdup(cur.path);
			strcat(tmp, "/");
			strcat(tmp, cur.file);
			
			int fd = open(tmp, O_CREAT | O_APPEND | O_WRONLY, 0666);

			if (fork())
			{
				wait();
			}
			else
			{
				dup2(fd, 1);
				
				char* thisfile = new char[255];
				thisfile = strdup(cur.path);
				strcat(thisfile, "/");
				strcat(thisfile, $3);
				
				cout << thisfile << endl;

				execlp("cat", "cat", thisfile, NULL);
			}
		}
	;


%%


