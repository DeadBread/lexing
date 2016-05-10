all: lister

try.cc: try.l
	flex -o try.cc try.l

trynext.cpp trynext.hpp: trynext.y
<<<<<<< HEAD
	bison -r all -d trynext.y --output trynext.cpp
=======
	bison -d trynext.y
>>>>>>> 9c7cb09... fucked-up Makefile bug fixed. Great changes are to come
lister: trynext.cpp try.cc
	g++ -o lister trynext.tab.c try.cc
clean: 
	rm try.cc trynext.cpp trynext.hpp

