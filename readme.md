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
$ ./rust.exe < "yourfile"   // Compiler yourfile.
$ make run                  // Compiler test/aMy.rust.
```

## Clean excess file
``` bash
$ make clean
```
