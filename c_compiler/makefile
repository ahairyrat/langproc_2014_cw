all:
	bison -d  --report=state -o CParser.cpp parse.y
	flex  -o CScanner.cpp flex_c.l
	g++ -o parser.out CScanner.cpp CParser.cpp src/FlexDef.cpp src/Parser.cpp
