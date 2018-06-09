# Compiler Project
---
## Description
2018 Summer Compiler Design assigment.

Compilier for Rust_.
* project1
    * Scanner done.

* project2
    * Parser done.
    * Change of scanner
        * Move **main()** to yacc, and use **yyparse()** instead of **yylex()**.
        * Symbol table rewrite.
        * Add **return**, and assign value to **yylval**:
            * Some string need return label that declare in yacc.
            * Do like: return **OP_EQUAL**, not return **"=="**.
* project3
    * I change to use argc argv.
    * Scanner was not changed.
    * In symbolTable
        * Need check ve isGlobal.
        * Keep function argument info.
    * In parser
        * Use **fstream** to write file to ***.jasm**.
        * Need check hasReturned, nowIsConstant.
        * Need keep nowStackIndex, nowLabelIndex.
        * I add whileKeep type to KE_WHILE to keep while labelIndex.
    * special
        * I keep labelIndex for mutilple stament.
        * Add "nop" to *.jasm to keep from syntex error of double label like
        ```
            ...                     ...
            L1:         --->        L1:
            L2:         --->            nop
            ...         --->        L2:
            ...                     ...
        ```

## Debug
``` c
#define LEX_PRINT           // Comment this to hide scanner info.
#define YACC_PRINT          // Comment this to hide parse info.
```

## Compiler lex yacc
``` bash
$ make
```

## Excute
``` bash
$ _rust.exe <filename>                      # Compiler <filename> to proj3.jasm.
$ _rust.exe <filename> <outputfileName>     # Compiler <filename> to <outputfileName>.jasm.
$ javaa/javaa <outputfileName>.jasm         # Compiler jasm to class.
$ java <outputfileName>                     # Run by java, should install java.

$ make allRun                               # Do all for test/_proj3.rust to proj3.class.
$ make run f=<filename>                     # Do all for <filename> to proj3.class.
$ make run f=<filename> o=<outputfileName>  # Do all for <filename> to <outputfileName>.class.
```

## Clean excess file
``` bash
$ make clean
```
