%{
#include <stdlib.h>
#include <stdio.h>
#include "y.tab.h"

extern "C"{
	int yywrap();
	int yylex();
}

%}

%%

"l"     	{ 
				yylval.Token.stringVal = yytext;
				return FARSTR; 
			}
r[lr]*     	{ 
				yylval.Token.stringVal = yytext;
				return FARSTR; 
			}

%%

// called by lexical analyzer if end of the input file.
int yywrap()
{
	// ...
	
	return 1;
}