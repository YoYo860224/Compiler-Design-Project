%{
#include <stdlib.h>
#include <stdio.h>
#define Trace(t)        printf(t)

int yyerror(char *s);
int yylex();
int create();
int dump();

%}

/* tokens */
%token SEMICOLON
%token INTEGER
%token STRING
%token REAL
%token ID

%token PLUS_PLUS

%%
program:        statements { Trace("Reducing to program\n"); }
            ;
statements:     statement               { Trace("Reducing to statements\n"); } 
            |   statement statements    { Trace("Reducing to statements\n"); } 
            ;
statement:      ID                      { Trace("Reducing to statement\n"); }
            |   ID ',' statement        { Trace("Reducing to statement\n"); }
            |   ID PLUS_PLUS            { Trace("Reducing to statement\n"); }
            ;
%%

int yyerror(char *s)
{
    fprintf(stderr, "%s\n", s);
    return 0;
}
int main(void)
{
    create();

    yyparse();
    return 0;

    dump();
}
