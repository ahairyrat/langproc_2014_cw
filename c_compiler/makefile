all:
	bison++ -d -hCParser.h -oCParser.cpp parse.y
	flex++  -d -oCScanner.cpp flex_c.l
	g++ CScanner.cpp CParser.cpp
