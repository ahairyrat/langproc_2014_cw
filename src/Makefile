CPPFLAGS += -g

all :
	bison -d -o CParser.cpp CParser.y
	flex	-o CLexer.cpp CLexer.l
	g++ $(CPPFLAGS) -o compiler.out $(wildcard *.cpp)
