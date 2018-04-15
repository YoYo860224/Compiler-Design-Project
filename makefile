LEX_FILE_NAME = rust_lex.l
GCC_OUT_FILENAME = rust_lex.out
RUNFILE_PATH = test.rs

main : $(LEX_FILE_NAME)
	flex $(LEX_FILE_NAME)
	gcc lex.yy.c -ll -o $(GCC_OUT_FILENAME)

run :
	#cat $(RUNFILE_PATH) | ./$(GCC_OUT_FILENAME)
	./$(GCC_OUT_FILENAME) < $(RUNFILE_PATH)