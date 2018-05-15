%{
#include <iostream>
#include <vector>
#include <stdlib.h>
#include <stdio.h>

#define Trace(t)        printf(t)

extern "C" {
    int yyerror(const char *s);
    extern int yylex();
}
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



int yyerror(const char *s)
{
    fprintf(stderr, "%s\n", s);
    return 0;
}

int main(void)
{
    // For test cpp function
    std::vector<int> a;
    a.push_back(1);
    std::cout << a[0] << "\n"; 
    std::cout << "Can use cpp function\n\n";

    yyparse();
    return 0;
}
