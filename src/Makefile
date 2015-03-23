CPPFLAGS += -W -Wall -g

all : compiler
	bison -d -o CParser.cpp CParser.y
	flex	-o CLexer.cpp CLexer.l
	g++ $(CPPFLAGS) -o compiler.out $(wildcard *.cpp)
