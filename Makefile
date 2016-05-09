all: lister

try.cc: try.l
	flex -o try.cc try.l

trynext.cpp trynext.hpp: trynext.y
	bison -r all -d trynext.y --output trynext.cpp
lister: trynext.cpp try.cc
	g++ -o lister trynext.cpp try.cc
clean: 
	rm try.cc trynext.cpp trynext.hpp

