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
	#include <sys/types.h>
    #include <sys/wait.h>


    using namespace std;

    extern int yylineno;
    extern int yyparse();
    extern int yylex();

    extern FILE *yyin;
    void yyerror(const char *s)
    {
    	if (s == NULL)
    		std::cerr << "syntax error" << ", line " << yylineno << std::endl;
    	else
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
    		delete [] file;
    		delete [] path;
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
%token WORD NUMBER STRING
%token CREATE MAKE ADD ADDALL COPY EXIT SORT COMPARE GOTO RENAME LST DIR END PRINT

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
	| compare
	| sort
	| copy 
	| rename
	| list
	| dir
	| concat
	| print
	| end
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
	GOTO STRING
		{
			if (chdir($2) >= 0)
				cur.path = get_current_dir_name();
			else 
				cerr << "wrong directory" << endl;
		}


new_cur:
	SIGN filename
		{
			if (cur.fd > 0) 
				close (cur.fd);
			cur.fd = open($2, O_WRONLY | O_APPEND, 0666);
			if (cur.fd < 0)
				cout << "file not opened!" << endl;
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
		if (cur.fd > 0) 
			close (cur.fd);
		cur.fd = open($2, O_WRONLY | O_CREAT | O_TRUNC,0666);
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
	MAKE STRING filename
	{
		if (cur.fd > 0) 
			close (cur.fd);
		cur.fd = open($3, O_WRONLY | O_CREAT | O_TRUNC,0666);
		
		if (cur.fd < 0)
			cout << "error opening file" << endl;
		else
		{

			if (fork()) {
				wait(NULL);
				cout << "creation complete" << endl;
			}
			else {
				//char* tmp = new char[255];
				//strcat(tmp, "\"");
				//strcat(tmp, cur.path);
				//strcat(tmp, "\"");

				dup2(cur.fd, 1);
				execlp("/home/kardamon/Documents/scripts/m3uer.sh", "m3uer.sh", $2, NULL);
			}

			cur.file = $3;
		}
	}
	| 
	MAKE filename
	{
		if (cur.fd > 0) 
			close (cur.fd);
		cur.fd = open($2 ,O_WRONLY | O_CREAT,0666);

		if (cur.fd < 0) 
			cout << "error opening file" << endl;
		else
		{
			if (fork()) {
				wait(NULL);
				cout << "creation complete" << endl;
			}
			else {
				//char* tmp = new char[255];
				//strcat(tmp, "\"");
				//strcat(tmp, cur.path);
				//strcat(tmp, "\"");

				dup2(cur.fd, 1);
				execlp("/home/kardamon/Documents/scripts/m3uer.sh", "m3uer.h", NULL);
			}

			cur.file = $2;
		}
	}
	;

add:
	ADD STRING	//надо изменить, ибо filename - не универсален
	{
		strcat($2, "\n");
		if (cur.fd < 0)
			cout << "no opened file!" << endl;
		else
			write(cur.fd, $2, strlen($2));
	}
	;

copy: 
	COPY path
	{
		if (cur.fd > 0)
			close(cur.fd);
		if (fork())
		{
			wait(NULL);
		}
		else
		{
			cout << "here" << endl;
 			execlp("rcp", "rcp", "-r", cur.file, $2, NULL);
		}

		cur.fd = open(cur.file, O_APPEND | O_WRONLY, 0666);
	}
	|
	COPY filename
	{
		if (cur.fd > 0)
			close(cur.fd);

		int pid = fork();
		if (pid)
		{
			wait(NULL);
		}
		else
		{
			execlp("rcp", "rcp", "-r", cur.file, $2, NULL);
		}

		cur.fd = open(cur.file, O_APPEND | O_WRONLY, 0666);
	}
	;

compare:
	COMPARE filename
	{
		if (fork())
		{
			wait(NULL);
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
			wait(NULL);
		}
		else
		{
			if (cur.fd < 0)
				close(cur.fd);
			cur.fd = open(cur.file, O_WRONLY, 0666);
			
			if (cur.fd < 0)
				cout << "error opening file" << endl;
			else
			{
				dup2(cur.fd, 1);
				execlp("sort", "sort" , cur.file, NULL);
			}
		}
	}
	|
	SORT DEF RIGHTBR filename
	{

		if (fork())
		{
			wait(NULL);
		}
		else
		{
			int fd = open($4, O_WRONLY | O_CREAT | O_TRUNC, 0666);

			if (cur.fd < 0)
				cout << "error opening file" << endl;
			else
			{
				dup2(fd, 1);
				execlp("sort", "sort", cur.file, NULL);
			}
		}
	}
	;

rename:
	RENAME filename
	{	
		
		if (rename(cur.file, $2)) printf("it goes wrong");
		cur.file = $2;

		if (cur.fd > 0)
			close (cur.fd);
		cur.fd = open($2, O_APPEND | O_WRONLY, 0666);
		
		if (cur.fd < 0)
			cout << "file not opened!" << endl;

		cout << "new name is" << $2 << endl;
	}
	; 

list:
	LST
	{
		if (fork())
		{
			wait(NULL);
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
			wait(NULL);
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
				wait(NULL);
			}
			else
			{
				//if (cur.fd > 0)
				//	close (cur.fd);
				//cur.fd = open(cur.file, O_WRONLY, O_APPEND, 0666);
				
				if (cur.fd < 0)
				{
					cout << "no file opened" << endl;
					exit(0);
				}
				else
				{
					dup2(cur.fd, 1);
					execlp("cat", "cat", $3, NULL);
				}
			}
		}
	;

print:
	PRINT
	{
		if (fork())
			wait(NULL);
		else
			execlp("cat", "cat", cur.file, NULL);
	}
	;

end:
	END
	{
		return 0;
	}


%%


