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
    	int fd;

    	Current_state()
    	{
    		file = new char[255];
    		path = new char[255];
    		path = get_current_dir_name();
    		fd = -1;
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
			chdir($2);
			cur.path = get_current_dir_name();
		}


new_cur:
	SIGN filename
		{
			if (cur.fd > 0) 
				close (cur.fd);
			cur.fd = open($2, O_WRONLY | O_APPEND, 0666);
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
		
		if (cur.fd > 0) 
			close (cur.fd);
		cur.fd = open(fname, O_WRONLY | O_CREAT | O_TRUNC,0666);

		if (cur.fd < 0) 
			{
				std::cerr << "error opening file!" << endl;
			}
		else
		{
			cur.file = $2;
			cout << "Creation complete!" << endl;
		}
	}
	;

make: 
	MAKE path filename
	{
		
		char* fname = new char[255];
		fname = strcpy(fname, cur.path);
		fname = strcat(strcat(fname, "/"), $3);

		if (cur.fd > 0) 
			close (cur.fd);
		cur.fd = open(fname, O_WRONLY | O_CREAT | O_TRUNC,0666);

		if (fork()) {
			wait();
			cout << "creation complete" << endl;
		}
		else {
			dup2(cur.fd, 1);
			execlp("/home/kardamon/Documents/scripts/m3uer.sh", "m3uer.sh", cur.path, $2, NULL);
		}

		delete(fname);

		cur.file = $3;
	}
	| 
	MAKE filename
	{

		char* fname = new char[255];
		fname = strcpy(fname, cur.path);
		fname = strcat(strcat(fname, "/"), $2);

		if (cur.fd > 0) 
			close (cur.fd);
		cur.fd = open(fname ,O_WRONLY | O_CREAT,0666);

		if (fork()) {
			wait();
			cout << "creation complete" << endl;
		}
		else {

			dup2(cur.fd, 1);
			execlp("/home/kardamon/Documents/scripts/m3uer.sh", "m3uer.h", cur.path, " " , ">", $2, NULL);
		}

		delete(fname);

		cur.file = $2;
	}
	;

add:
	ADD filename	//надо изменить, ибо filename - не универсален
	{
		strcat($2, "\n");

		write(cur.fd, $2, strlen($2));
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
	SORT SIGN
	{
		if (fork())
		{
			wait();
		}
		else
		{
			char* tmp = new char[255];
			tmp = strdup(cur.path);
			strcat(tmp, "/");
			strcat(tmp, cur.file);

			if (cur.fd < 0)
				close(cur.fd);
			cur.fd = open(tmp, O_WRONLY, 0666);
			dup2(cur.fd, 1);
			execlp("sort", "sort" , tmp, NULL);
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
			char*tmpfile = new char[255];
			tmpfile = strdup(cur.path);
			strcat(tmpfile, "/");
			strcat(tmpfile, $4);
			int fd = open(tmpfile, O_WRONLY | O_CREAT | O_TRUNC, 0666);

			dup2(fd, 1);

			char* tmp = new char[255];
			tmp = strdup(cur.path);
			strcat(tmp, "/");
			strcat(tmp, cur.file);

			execlp("sort", "sort", tmp, NULL);
		}
	}
	;

rename:
	RENAME filename
	{	
		
		if (rename(cur.file, $2)) printf("it goes wrong");
		cur.file = $2;

		char* tmp = new char[255];
		tmp = strdup(cur.path);
		strcat(tmp, "/");
		strcat(tmp, $2);

		if (cur.fd > 0)
			close (cur.fd);
		cur.fd = open(tmp, O_APPEND | O_WRONLY, 0666);

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
			if (fork())
			{
				wait();
			}
			else
			{
				dup2(cur.fd, 1);
				
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


