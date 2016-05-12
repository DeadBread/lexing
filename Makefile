all: lister

try.cc: try.l
	flex -o try.cc try.l

trynext.cpp trynext.hpp: trynext.y
	bison -d trynext.y

lister: trynext.cpp try.cc
	g++ -o lister trynext.tab.c try.cc
clean: 
	rm try.cc trynext.cpp trynext.hpp

