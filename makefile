LEX_FILE_NAME = rust_lex.l
YACC_FILE_NAME = rust_yacc.y
GCC_OUT_FILENAME = rust.out
RUNFILE_PATH = test.rs

main : $(LEX_FILE_NAME)
	bison -y -d $(YACC_FILE_NAME)
	flex $(LEX_FILE_NAME)
	gcc lex.yy.c y.tab.c -ll -ly -o $(GCC_OUT_FILENAME)

run :
	./$(GCC_OUT_FILENAME) < $(RUNFILE_PATH)

clean :
	rm -f *.c *.h
