%{
// =============================== Don't mind in exam.=================================
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

extern "C" {
	int yyerror(const char *s);
	extern int yylex();
	extern int yylineno;
	extern FILE* yyin;
}

using namespace std;
// ===================================================================================

fstream fp;

%}
%union{
	struct{
		char* stringVal;
	} Token;
}


%token <Token> FARSTR

%start program

%%
program:	FARSTR			{ 
								// process output
								char* oriStr = $1.stringVal;
								char biStr[100];
								int decInt = 0;
								for(int i = 0;i < strlen($1.stringVal); i++)
								{
									if (oriStr[i] == 'l')
									{	
										biStr[i] = '0';
										decInt *= 2;									
									} else
									{
										biStr[i] = '1';
										decInt *= 2;
										decInt += 1;
									}
								}
								biStr[strlen($1.stringVal)] = '\0';
								
								// file write
								fp << "\t\tgetstatic java.io.PrintStream java.lang.System.out" << endl;
								fp << "\t\tldc \"" << $1.stringVal << "=>" << biStr << "=>" << decInt << "\""<< endl;
								fp << "\t\tinvokevirtual void java.io.PrintStream.println(java.lang.String)" << endl;
							}
%%

// =============================== Don't mind in exam.=================================
int yyerror(const char *s)
{
	fprintf(stderr, "ERROR: %s at line number:%d\n", s, yylineno);
	exit(-1);
	return 0;
}
// ===================================================================================

int main(int argc, char *argv[])
{
    // =============================== Don't mind in exam.=================================
	// Open srcfile.
	if (argc != 2)
	{
        fprintf(stderr, "Usage: _rust.exe <filename>\n");
        exit(-1);
    }

	yyin = fopen(argv[1], "r");

	if (!yyin) 
	{
		fprintf(stderr, "ERROR: Fail to open %s\n", argv[1]);
		exit(-1);
	}

	// ===================================================================================

	// Write jasm.
	fp.open("finalExam.jasm", std::ios::out);	

	// class dec
	fp << "class finalExam" << endl;
	fp << "{" << endl;

	// main dec
	fp << "\tmethod public static void main(java.lang.String[])" << endl;
	fp << "\tmax_stack 15" << endl;
	fp << "\tmax_locals 15" << endl;
	fp << "\t{" << endl;
	
	yyparse();

	// main out
	fp << "\t\treturn" << endl;
	fp << "\t}" << endl;

	// class out
	fp << "}";

    fp.close();

	return 0;
}