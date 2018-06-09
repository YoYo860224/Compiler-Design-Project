CC = g++
LEX = flex
YACC = bison
LEX_FILENAME = rust_lex.l
YACC_FILENAME = rust_yacc.y
OUTPUT_FILENAME = _rust.exe
TEST_FILENAME = ./test/_proj3.rust
OTHER_SOURCE = symbol.cpp

$(OUTPUT_FILENAME): clean lex.yy.o y.tab.o
	$(CC) lex.yy.o y.tab.o $(OTHER_SOURCE) -o $(OUTPUT_FILENAME)
	rm -f lex.yy.cpp y.tab.cpp y.tab.h  *.o

lex.yy.o: lex.yy.cpp y.tab.h
	$(CC) -c lex.yy.cpp

y.tab.o: y.tab.cpp
	$(CC) -c y.tab.cpp

y.tab.cpp y.tab.h: $(YACC_FILENAME)
	$(YACC) -y -d $(YACC_FILENAME)
	mv y.tab.c y.tab.cpp

lex.yy.cpp: $(LEX_FILENAME)
	$(LEX) -o lex.yy.cpp $(LEX_FILENAME)

clean:
	rm -f lex.yy.cpp y.tab.cpp y.tab.h  *.o *.exe *.class *.jasm

fixedRun: getJasm getClass excuteJava

getJasm: $(TEST_FILENAME)
	./$(OUTPUT_FILENAME) $(TEST_FILENAME)

getClass: proj3.jasm
	javaa/javaa proj3.jasm

excuteJava: proj3.class
	java proj3

run:
ifdef f
ifdef o
	./$(OUTPUT_FILENAME) $(f) $(o)
	javaa/javaa $(o).jasm
	java $(o)
else
	./$(OUTPUT_FILENAME) $(f)
	javaa/javaa proj3.jasm
	java proj3
endif
endif
