%{
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <stdlib.h>
#include <stdio.h>
#include "symbol.h"

#define YACC_PRINT

#ifdef YACC_PRINT
#define Trace(t)		printf(t)
#else
#define Trace(t)
#endif

extern "C" {
	int yyerror(const char *s);
	extern int yylex();
	extern int yylineno;
	extern FILE* yyin;
}

using namespace std;

// Declare for file.
string outputfileName = "proj3";
fstream fp;
int nowTabs = 0;
void printTabs();

// Global symbol table.
symbolTables symTabs = symbolTables();

// Some global for check.
bool hasReturned = false;
bool nowIsConstant = false;
int nowStackIndex = 0;
int nowLabelIndex = 0;

vector<int> topElseLabel;

%}

/* tokens */
%union{
	struct{
		int tokenType; 		// define enum in symbol.h
		bool notInit;
		union{
			int intVal;
			float floatVal;
			bool boolVal;
			char* stringVal;
		};
	} Token;
}

%union{
	struct{
		int beginLabel;
		int exitLabel;
	} whileKeep;
}

%token OP_INCREMENT
%token OP_DECREMENT
%token OP_LESS_EQUAL
%token OP_GREAT_EQUAL
%token OP_EQUAL
%token OP_NOT_EQUAL
%token OP_AND
%token OP_OR
%token OP_ADDITION_ASSIGNMENT
%token OP_SUBTRACTION_ASSIGNMENT
%token OP_MULTIPLICATION_ASSIGNMENT
%token OP_DIVISION_ASSIGNMENT

%token KW_BOOL
%token KW_BREAK
%token KW_CHAR
%token KW_CONTINUE
%token KW_DO
%token KW_ENUM
%token KW_EXTERN
%token KW_FALSE
%token KW_FLOAT
%token KW_FOR
%token KW_FN
%token KW_IN
%token KW_INT
%token KW_LET
%token KW_LOOP
%token KW_MATCH
%token KW_MUT
%token KW_PRINT
%token KW_PRINTLN
%token KW_PUB
%token KW_RETURN
%token KW_SELF
%token KW_STATIC
%token KW_STR
%token KW_STRUCT
%token KW_TRUE
%token KW_USE
%token KW_WHERE
%token KW_IF
%token KW_ELSE

%token <whileKeep> KW_WHILE

%token <Token> INTEGER
%token <Token> STRING
%token <Token> REAL
%token <Token> ID

%type <Token> arrDec type expression integerExpr realExpr boolExpr stringExpr functionInvoc

%start program

%left OP_OR
%left OP_AND
%left '!'
%left '>' '<' OP_GREAT_EQUAL OP_EQUAL OP_LESS_EQUAL OP_NOT_EQUAL
%left '+' '-'
%left '*' '/' '%'
%nonassoc UMINUS

%%
program:		declarations functionDecs	{
												Trace("Reducing to program Form declarations functionDecs\n");

												symTabs.pop_table();
											}
			|	functionDecs				{
												Trace("Reducing to program Form functionDecs\n");

												symTabs.pop_table();
											}
			;

declarations:	declaration					{ Trace("Reducing to declarations Form declaration\n"); }
			|	declaration declarations	{ Trace("Reducing to declarations Form declaration declarations\n"); }
			;

declaration:	varDec						{ Trace("Reducing to declaration Form varDec\n"); }
			|	constDec					{ Trace("Reducing to declaration Form constDec\n"); }
			|	arrDec						{ Trace("Reducing to declaration Form arrDec\n"); }
			;

type:			KW_INT						{
												Trace("Reducing to type Form KW_INT\n");

												$$.tokenType = T_INT;
											}
			|	KW_FLOAT					{
												Trace("Reducing to type Form KW_FLOAT\n");

												$$.tokenType = T_FLOAT;
											}
			|	KW_BOOL						{
												Trace("Reducing to type Form KW_BOOL\n");

												$$.tokenType = T_BOOL;
											}
			|	KW_STR						{
												Trace("Reducing to type Form KW_STR\n");

												$$.tokenType = T_STRING;
											}
			;

varDec:			KW_LET KW_MUT ID ':' type ';'					{
																	Trace("Reducing to varDec Form KW_LET KW_MUT ID ':' type ';'\n");

																	variableEntry ve = ve_basic_notInit($3.stringVal, $5.tokenType, false);

																	if (symTabs.isNowGlobal())
																	{
																		ve.isGlobal = true;

																		printTabs();
																		if (ve.type== T_INT)
																			fp << "field static int " << ve.name << endl;
																		else if (ve.type == T_BOOL)
																			fp << "field static int " << ve.name << endl;
																	}
																	else
																	{
																		ve.isGlobal = false;
																		ve.stackIndex = nowStackIndex;
																		nowStackIndex++;
																	}

																	if (!symTabs.addVariable(ve))
																		yyerror("Re declaration.");
																}
			|	KW_LET KW_MUT ID '=' expression	';'				{
																	Trace("Reducing to varDec Form KW_LET KW_MUT ID '=' expression	';'\n");

																	variableEntry ve = ve_basic($3.stringVal, $5.tokenType, false);

																	if ($5.tokenType == T_INT)
																		ve.data.intVal = $5.intVal;
																	else if ($5.tokenType == T_FLOAT)
																		ve.data.floatVal = $5.floatVal;
																	else if ($5.tokenType == T_BOOL)
																		ve.data.boolVal = $5.boolVal;
																	else if ($5.tokenType == T_STRING)
																		ve.data.stringVal = $5.stringVal;

																	if (symTabs.isNowGlobal())
																	{
																		ve.isGlobal = true;

																		printTabs();
																		if (ve.type == T_INT)
																			fp << "field static int " << ve.name << " = " << ve.data.intVal << endl;
																		else if (ve.type == T_BOOL)
																			fp << "field static int " << ve.name << " = " << ve.data.boolVal << endl;
																	}
																	else
																	{
																		ve.isGlobal = false;
																		ve.stackIndex = nowStackIndex;
																		nowStackIndex++;

																		printTabs();
																		if (ve.type == T_INT)
																			fp << "istore " << ve.stackIndex << endl;
																		else if (ve.type == T_BOOL)
																			fp << "istore " << ve.stackIndex << endl;
																	}

																	if (!symTabs.addVariable(ve))
																		yyerror("Re declaration.");
																}
			|	KW_LET KW_MUT ID ':' type '=' expression ';'	{
																	Trace("Reducing to varDec Form KW_LET KW_MUT ID ':' type '=' expression ';'\n");

																	variableEntry ve = ve_basic($3.stringVal, $5.tokenType, false);

																	if ($5.tokenType == T_FLOAT && $7.tokenType == T_INT)
																		ve.data.floatVal = $7.intVal;
																	else if ($5.tokenType != $7.tokenType)
																		yyerror("expression is not equal to expression");
																	else if ($7.tokenType == T_INT)
																		ve.data.intVal = $7.intVal;
																	else if ($7.tokenType == T_FLOAT)
																		ve.data.floatVal = $7.floatVal;
																	else if ($7.tokenType == T_BOOL)
																		ve.data.boolVal = $7.boolVal;
																	else if ($7.tokenType == T_STRING)
																		ve.data.stringVal = $7.stringVal;

																	if (symTabs.isNowGlobal())
																	{
																		ve.isGlobal = true;

																		printTabs();
																		if (ve.type == T_INT)
																			fp << "field static int " << ve.name << " = " << ve.data.intVal << endl;
																		else if (ve.type == T_BOOL)
																			fp << "field static int " << ve.name << " = " << ve.data.boolVal << endl;
																	}
																	else
																	{
																		ve.isGlobal = false;
																		ve.stackIndex = nowStackIndex;
																		nowStackIndex++;

																		printTabs();
																		if (ve.type == T_INT)
																			fp << "istore " << ve.stackIndex << endl;
																		else if (ve.type == T_BOOL)
																			fp << "istore " << ve.stackIndex << endl;
																	}

																	if (!symTabs.addVariable(ve))
																		yyerror("Re declaration.");
																}
			|	KW_LET KW_MUT ID ';'							{
																	Trace("Reducing to varDec Form KW_LET KW_MUT ID ';'\n");

																	variableEntry ve = ve_basic_notInit($3.stringVal, T_INT, false);

																	if (symTabs.isNowGlobal())
																	{
																		ve.isGlobal = true;

																		printTabs();
																		fp << "field static int " << ve.name << endl;
																	}
																	else
																	{
																		ve.isGlobal = false;
																		ve.stackIndex = nowStackIndex;
																		nowStackIndex++;
																	}

																	if (!symTabs.addVariable(ve))
																		yyerror("Re declaration.");
																}
			;

constDec:		KW_LET ID '=' 									{
																	nowIsConstant = true;
																}
				expression ';'									{
																	Trace("Reducing to constDec Form KW_LET ID '=' expression ';'\n");

																	variableEntry ve = ve_basic($2.stringVal, $5.tokenType, true);

																	if ($5.tokenType == T_INT)
																		ve.data.intVal = $5.intVal;
																	else if ($5.tokenType == T_FLOAT)
																		ve.data.floatVal = $5.floatVal;
																	else if ($5.tokenType == T_BOOL)
																		ve.data.boolVal = $5.boolVal;
																	else if ($5.tokenType == T_STRING)
																		ve.data.stringVal = $5.stringVal;

																	if (!symTabs.addVariable(ve))
																		yyerror("Re declaration.");

																	nowIsConstant = false;
																}
			|	KW_LET ID ':' type 								{
																	nowIsConstant = true;
																}
			'=' expression ';'									{
																	Trace("Reducing to constDec Form KW_LET ID ':' type '=' expression ';'\n");

																	variableEntry ve = ve_basic($2.stringVal, $4.tokenType, true);

																	if ($4.tokenType == T_FLOAT && $7.tokenType == T_INT)
																		ve.data.floatVal = $7.intVal;
																	else if ($4.tokenType != $7.tokenType)
																		yyerror("expression is not equal to expression");
																	else if ($7.tokenType == T_INT)
																		ve.data.intVal = $7.intVal;
																	else if ($7.tokenType == T_FLOAT)
																		ve.data.floatVal = $7.floatVal;
																	else if ($7.tokenType == T_BOOL)
																		ve.data.boolVal = $7.boolVal;
																	else if ($7.tokenType == T_STRING)
																		ve.data.stringVal = $7.stringVal;

																	if (!symTabs.addVariable(ve))
																		yyerror("Re declaration.");

																	nowIsConstant = false;
																}
			;

arrDec:			KW_LET KW_MUT ID '[' type ',' expression ']' ';'	{
																		Trace("Reducing to arrDec Form KW_LET KW_MUT ID '[' type ',' expression ']' ';'\n");

																		variableEntry ve = ve_arr( $3.stringVal, $5.tokenType, false, $7.intVal);

																		if ($7.tokenType != T_INT)
																			yyerror("Array index not integer");

																		int size = $7.intVal;

																		if ($5.tokenType == T_INT)
																			ve.data.intArr = new int[size];
																		else if ($5.tokenType == T_FLOAT)
																			ve.data.floatArr = new float[size];
																		else if ($5.tokenType == T_BOOL)
																			ve.data.boolArr = new bool[size];
																		else if ($5.tokenType == T_STRING)
																		{
																			ve.data.stringArr = new char*[size];
																			for (int i = 0; i < size; i++)
																			{
																				ve.data.stringArr[i] = new char[0];
																				//ve.data.stringArr[i][0] = '0';
																			}
																		}

																		if (!symTabs.addVariable(ve))
																			yyerror("Re declaration.");
																	}
			;

functionDecs:	functionDec					{ Trace("Reducing to functionDecs Form functionDec\n"); }
			|	functionDec functionDecs	{ Trace("Reducing to functionDecs Form functionDec functionDecs\n"); }
			;

functionDec:	KW_FN ID '('				{
												variableEntry ve = ve_fn($2.stringVal, T_NONE);
												if (!symTabs.addVariable(ve))
													yyerror("Re declaration.");

												symTabs.push_table($2.stringVal);
												nowStackIndex = 0;
												hasReturned = false;

												printTabs();
												fp << "method public static ";
											}
			 	formalArgs ')' fnType		{
												variableEntry ve = symTabs.nowFuncVE();
												if (ve.name == "main")
													fp << "void main(java.lang.String[])" << endl;
												else
												{
													if (ve.type == T_INT)
														fp << "int ";
													else if (ve.type == T_BOOL)
														fp << "bool ";

													fp << ve.name;
													fp << "(";

													for (int i = 0; i < ve.argSize; i++)
													{
														if (ve.argType[i] == T_INT)
															fp << "int";
														else if (ve.argType[i] == T_BOOL)
															fp << "bool";

														if (i != ve.argSize - 1)
															fp << ", ";
													}

													fp << ")" << endl;
												}

												printTabs();
												fp << "max_stack 15" << endl;
												printTabs();
												fp << "max_locals 15" << endl;
												printTabs();
												fp << "{" << endl;
												nowTabs++;
				 							}
				fnScope						{
												Trace("Reducing to functionDec Form KW_FN ID '(' formalArgs ')' fnType fnScope\n");

												symTabs.pop_table();

												if (!hasReturned) {
													printTabs();
													fp << "return" << endl;
												}

												nowTabs--;
												printTabs();
												fp << "}" << endl;
											}
				;

formalArgs:		ID ':' type 				{
												Trace("Reducing to formalArgs Form ID ':' type\n");

												variableEntry ve = ve_basic($1.stringVal, $3.tokenType, false);

												ve.isGlobal = false;
												ve.stackIndex = nowStackIndex;
												nowStackIndex++;

												if (!symTabs.addVariable(ve))
													yyerror("Re declaration.");

												symTabs.addArgToPreloadFN($3.tokenType);
											}
			|	formalArgs ',' ID ':' type 	{
												Trace("Reducing to formalArgs Form formalArgs ',' ID ':' type\n");

												variableEntry ve = ve_basic($3.stringVal, $5.tokenType, false);

												ve.isGlobal = false;
												ve.stackIndex = nowStackIndex;
												nowStackIndex++;

												if (!symTabs.addVariable(ve))
													yyerror("Re declaration.");

												symTabs.addArgToPreloadFN($5.tokenType);
											}
			|	%empty						{ Trace("Reducing to formalArgs Form empty ':' type\n"); }
			;

fnType:			'-' '>' type				{
												Trace("Reducing to fnScope Form '-' '>' type\n");

												symTabs.addRetToPreloadFN($3.tokenType);
											}
			|	%empty						{ Trace("Reducing to fnType Form empty\n"); }

fnScope:		'{' scopeContent '}'		{ Trace("Reducing to fnScope Form '{' scopeContent '}'\n"); }
			;

scopeContent:	declarations scopeContent	{ Trace("Reducing to scopeContent Form declarations scopeContent\n"); }
			|	statements scopeContent		{ Trace("Reducing to scopeContent Form statements scopeContent\n"); }
			|	declarations				{ Trace("Reducing to scopeContent Form declarations\n"); }
			|	statements					{ Trace("Reducing to scopeContent Form statements\n"); }
			|	%empty						{ Trace("Reducing to scopeContent Form empty\n"); }
			;

statements:		statement statements		{ Trace("Reducing to statements Form statement statements\n"); }
			|	statement					{ Trace("Reducing to statements Form statement\n"); }
			;

statement:		ID '=' expression ';'						{
																Trace("Reducing to statement Form ID '=' expression ';'\n");

																variableEntry ve = symTabs.lookup($1.stringVal);
																if (ve.type == T_404)
																	yyerror("ID not found");
																else if (ve.isConst == true)
																	yyerror("Constant can't be assign");
																else if (ve.isFn)
																	yyerror("Function can't be assign");
																else if (ve.type == T_NONE)
																	ve.type = $3.tokenType;

																if (ve.type == T_FLOAT && $3.tokenType == T_INT)
																		ve.data.floatVal = $3.intVal;
																else if (ve.type != $3.tokenType)
																	yyerror("expression is not equal to expression");
																else if (ve.type == T_INT)
																	ve.data.intVal = $3.intVal;
																else if (ve.type == T_FLOAT)
																	ve.data.floatVal = $3.floatVal;
																else if (ve.type == T_BOOL)
																	ve.data.boolVal = $3.boolVal;
																else if (ve.type == T_STRING)
																	ve.data.stringVal = $3.stringVal;

																ve.isInit = true;
																symTabs.editVariable(ve);

																if (ve.isGlobal)
																{
																	printTabs();
																	fp << "putstatic int " << outputfileName << "." << ve.name << endl;
																}
																else
																{
																	printTabs();
																	fp << "istore " << ve.stackIndex << endl;
																}
															}
			|	ID '[' expression']' '=' expression ';'		{
																Trace("Reducing to statement Form ID '[' expression']' '=' expression ';'\n");

																variableEntry ve = symTabs.lookup($1.stringVal);
																if ($3.tokenType != T_INT)
																	yyerror("Array index not integer");

																int index = $3.intVal;

																if (ve.type == T_404)
																	yyerror("ID not found");
																else if (!ve.isArr)
																	yyerror("Not Array, can't use '[]'");
																else if (index >= ve.arrSize)
																	yyerror("Out of index");
																else
																{
																	if (ve.type == T_FLOAT && $6.tokenType == T_INT)
																		ve.data.floatArr[index] = $6.intVal;
																	else if (ve.type != $6.tokenType)
																		yyerror("expression is not equal to expression");
																	else if (ve.type == T_INT)
																		ve.data.intArr[index] = $6.intVal;
																	else if (ve.type == T_FLOAT)
																		ve.data.floatArr[index] = $6.floatVal;
																	else if (ve.type == T_BOOL)
																		ve.data.boolArr[index] = $6.boolVal;
																	else if (ve.type == T_STRING)
																		ve.data.stringArr[index] = $6.stringVal;

																	ve.isInit = true;
																	symTabs.editVariable(ve);
																}
															}
			|	KW_PRINT 									{
																printTabs();
																fp << "getstatic java.io.PrintStream java.lang.System.out" << endl;
															}
				expression	';'								{
																Trace("Reducing to statement Form KW_PRINT expression	';'\n");

																printTabs();
																fp << "invokevirtual void java.io.PrintStream.print(";
																if ($3.tokenType == T_INT)
																	fp << "int)" << endl;
																else if ($3.tokenType == T_BOOL)
																	fp << "boolean)" << endl;
																else if ($3.tokenType == T_STRING)
																	fp << "java.lang.String)" << endl;
															}
			|	KW_PRINTLN 									{
																printTabs();
																fp << "getstatic java.io.PrintStream java.lang.System.out" << endl;
															}
				expression ';'								{
																Trace("Reducing to statement Form KW_PRINTLN expression ';'\n");

																printTabs();
																fp << "invokevirtual void java.io.PrintStream.println(";
																if ($3.tokenType == T_INT)
																	fp << "int)" << endl;
																else if ($3.tokenType == T_BOOL)
																	fp << "boolean)" << endl;
																else if ($3.tokenType == T_STRING)
																	fp << "java.lang.String)" << endl;
															}
			|	KW_RETURN expression ';'					{
																Trace("Reducing to statement Form KW_RETURN expression ';'\n");

																hasReturned = true;
																printTabs();
																fp << "ireturn" << endl;
															}
			|	KW_RETURN ';'								{
																Trace("Reducing to statement Form KW_RETURN ';'\n");

																hasReturned = true;
																printTabs();
																fp << "return" << endl;
															}
			|	block										{ Trace("Reducing to statement Form block\n"); }
			|	ifStament									{ Trace("Reducing to statement Form ifStament\n"); }
			|	loop										{ Trace("Reducing to statement Form loop\n"); }
			|	functionInvoc								{ Trace("Reducing to statement Form functionInvoc\n"); }
			;

expression:		'-' expression %prec UMINUS					{
																Trace("Reducing to expression Form '-' expression\n");

																$$ = $2;
																if ($$.tokenType == T_INT)
																	$$.intVal *= -1;
																else if ($$.tokenType == T_FLOAT)
																	$$.floatVal *= -1;
																else
																	yyerror("'-' arg type error.");
																if (!nowIsConstant && !symTabs.isNowGlobal()) 
																{
																	printTabs();
																	fp << "ineg" << endl;
																}
															}
			|	expression '+' expression					{
																Trace("Reducing to expression Form expression '+' expression\n");

																if ($1.notInit)
																	yyerror("'+' left arg is not initial.");
																if ($3.notInit)
																	yyerror("'+' right arg is not initial.");

																if ($1.tokenType == T_INT && $3.tokenType == T_INT)
																{
																	$$.tokenType = T_INT;
																	$$.intVal = $1.intVal + $3.intVal;
																}
																else if ($1.tokenType == T_FLOAT && $3.tokenType == T_FLOAT)
																{
																	$$.tokenType = T_FLOAT;
																	$$.floatVal = $1.floatVal + $3.floatVal;
																}
																else if ($1.tokenType == T_INT && $3.tokenType == T_FLOAT)
																{
																	$$.tokenType = T_FLOAT;
																	$$.floatVal = $1.intVal + $3.floatVal;
																}
																else if ($1.tokenType == T_FLOAT && $3.tokenType == T_INT)
																{
																	$$.tokenType = T_FLOAT;
																	$$.floatVal = $1.floatVal + $3.intVal;
																}
																else
																	yyerror("'+' arg type error.");

																if (!nowIsConstant && !symTabs.isNowGlobal()) 
																{
																	printTabs();
																	fp << "iadd" << endl;
																}
															}
			|	expression '-' expression					{
																Trace("Reducing to expression Form expression '-' expression\n");

																if ($1.notInit)
																	yyerror("'-' left arg is not initial.");
																if ($3.notInit)
																	yyerror("'-' right arg is not initial.");

																if ($1.tokenType == T_INT && $3.tokenType == T_INT)
																{
																	$$.tokenType = T_INT;
																	$$.intVal = $1.intVal - $3.intVal;
																}
																else if ($1.tokenType == T_FLOAT && $3.tokenType == T_FLOAT)
																{
																	$$.tokenType = T_FLOAT;
																	$$.floatVal = $1.floatVal - $3.floatVal;
																}
																else if ($1.tokenType == T_INT && $3.tokenType == T_FLOAT)
																{
																	$$.tokenType = T_FLOAT;
																	$$.floatVal = $1.intVal - $3.floatVal;
																}
																else if ($1.tokenType == T_FLOAT && $3.tokenType == T_INT)
																{
																	$$.tokenType = T_FLOAT;
																	$$.floatVal = $1.floatVal - $3.intVal;
																}
																else
																	yyerror("'-' arg type error.");

																if (!nowIsConstant && !symTabs.isNowGlobal()) 
																{
																	printTabs();
																	fp << "isub" << endl;
																}
															}
			|	expression '*' expression					{
																Trace("Reducing to expression Form expression '*' expression\n");

																if ($1.notInit)
																	yyerror("'*' left arg is not initial.");
																if ($3.notInit)
																	yyerror("'*' right arg is not initial.");

																if ($1.tokenType == T_INT && $3.tokenType == T_INT)
																{
																	$$.tokenType = T_INT;
																	$$.intVal = $1.intVal * $3.intVal;
																}
																else if ($1.tokenType == T_FLOAT && $3.tokenType == T_FLOAT)
																{
																	$$.tokenType = T_FLOAT;
																	$$.floatVal = $1.floatVal * $3.floatVal;
																}
																else if ($1.tokenType == T_INT && $3.tokenType == T_FLOAT)
																{
																	$$.tokenType = T_FLOAT;
																	$$.floatVal = $1.intVal * $3.floatVal;
																}
																else if ($1.tokenType == T_FLOAT && $3.tokenType == T_INT)
																{
																	$$.tokenType = T_FLOAT;
																	$$.floatVal = $1.floatVal * $3.intVal;
																}
																else
																	yyerror("'*' arg type error.");

																
																if (!nowIsConstant && !symTabs.isNowGlobal()) 
																{
																	printTabs();
																	fp << "imul" << endl;
																}
															}
			|	expression '/' expression					{
																Trace("Reducing to expression Form expression '/' expression\n");

																if ($1.notInit)
																	yyerror("'/' left arg is not initial.");
																if ($3.notInit)
																	yyerror("'/' right arg is not initial.");

																if ($1.tokenType == T_INT && $3.tokenType == T_INT)
																{
																	$$.tokenType = T_INT;
																	$$.intVal = $1.intVal / $3.intVal;
																}
																else if ($1.tokenType == T_FLOAT && $3.tokenType == T_FLOAT)
																{
																	$$.tokenType = T_FLOAT;
																	$$.floatVal = $1.floatVal / $3.floatVal;
																}
																else if ($1.tokenType == T_INT && $3.tokenType == T_FLOAT)
																{
																	$$.tokenType = T_FLOAT;
																	$$.floatVal = $1.intVal / $3.floatVal;
																}
																else if ($1.tokenType == T_FLOAT && $3.tokenType == T_INT)
																{
																	$$.tokenType = T_FLOAT;
																	$$.floatVal = $1.floatVal / $3.intVal;
																}
																else
																	yyerror("'/' arg type error.");

																if (!nowIsConstant && !symTabs.isNowGlobal()) 
																{
																	printTabs();
																	fp << "idiv" << endl;
																}
															}
			|	expression '%' expression					{
																Trace("Reducing to expression Form expression '%%' expression\n");

																if ($1.notInit)
																	yyerror("'%' left arg is not initial.");
																if ($3.notInit)
																	yyerror("'%' right arg is not initial.");

																if ($1.tokenType == T_INT && $3.tokenType == T_INT)
																{
																	$$.tokenType = T_INT;
																	$$.intVal = $1.intVal % $3.intVal;
																}
																else
																	yyerror("'%' arg type error.");

																if (!nowIsConstant && !symTabs.isNowGlobal()) 
																{
																	printTabs();
																	fp << "irem" << endl;
																}
															}
			|	'(' expression ')'							{
																Trace("Reducing to expression Form '(' expression ')'\n");

																$$ = $2;
															}
			|	integerExpr									{ Trace("Reducing to expression Form integerExpr\n"); }
			|	realExpr									{ Trace("Reducing to expression Form realExpr\n"); }
			|	boolExpr									{ Trace("Reducing to expression Form boolExpr\n"); }
			|	stringExpr									{ Trace("Reducing to expression Form stringExpr\n"); }
			|	functionInvoc								{
																Trace("Reducing to expression Form functionInvoc\n");

																if ($1.tokenType == T_NONE)
																	yyerror("The function no return, can not be expression.");
																$$.tokenType = $1.tokenType;
															}
			|	ID											{
																Trace("Reducing to expression Form ID\n");

																variableEntry ve = symTabs.lookup($1.stringVal);
																if (ve.type == T_404)
																	yyerror("ID not found");
																else if (ve.type == T_NONE)
																	$$.notInit = true;
																else if (ve.isArr)
																	yyerror("Array no give index");
																else if (ve.isFn)
																	yyerror("Function no parameters");
																else
																{
																	if (ve.type == T_INT)
																	{
																		$$.tokenType = T_INT;
																		$$.intVal = ve.data.intVal;
																	}
																	else if (ve.type == T_FLOAT)
																	{
																		$$.tokenType = T_FLOAT;
																		$$.floatVal = ve.data.floatVal;
																	}
																	else if (ve.type == T_BOOL)
																	{
																		$$.tokenType = T_BOOL;
																		$$.boolVal = ve.data.boolVal;
																	}
																	else if (ve.type == T_STRING)
																	{
																		$$.tokenType = T_STRING;
																		$$.stringVal = ve.data.stringVal;
																	}
																}

																if (ve.isConst)
																{
																	printTabs();
																	if (ve.type == T_INT)
																		fp << "sipush " << ve.data.intVal << endl;
																	else if (ve.type == T_BOOL)
																		fp << "iconst_" << ve.data.boolVal << endl;
																	else if (ve.type == T_STRING)
																		fp << "ldc \"" << ve.data.stringVal << "\"" << endl;
																}
																else
																{
																	if (ve.isGlobal)
																	{
																		printTabs();
																		fp << "getstatic int " << outputfileName << "." << ve.name << endl;
																	}
																	else
																	{
																		printTabs();
																		if (ve.type == T_INT)
																			fp << "iload " << ve.stackIndex << endl;
																		else if (ve.type == T_BOOL)
																			fp << "iload " << ve.stackIndex << endl;
																	}
																}
															}
			|	ID '[' expression ']'						{
																Trace("Reducing to expression Form ID '[' expression ']'\n");

																variableEntry ve = symTabs.lookup($1.stringVal);

																if ($3.tokenType != T_INT)
																	yyerror("Array index not integer");

																int index = $3.intVal;

																if (ve.type == T_404)
																	yyerror("ID not found");
																else if (!ve.isArr)
																	yyerror("Not Array, can't use '[]'");
																else
																{
																	if (ve.type == T_INT)
																	{
																		$$.tokenType = T_INT;
																		$$.intVal = ve.data.intArr[index];
																	}
																	else if (ve.type == T_FLOAT)
																	{
																		$$.tokenType = T_FLOAT;
																		$$.floatVal = ve.data.floatArr[index];
																	}
																	else if (ve.type == T_BOOL)
																	{
																		$$.tokenType = T_BOOL;
																		$$.boolVal = ve.data.boolArr[index];
																	}
																	else if (ve.type == T_STRING)
																	{
																		$$.tokenType = T_STRING;
																		$$.stringVal = ve.data.stringArr[index];
																	}
																	else
																		yyerror("Array no give index");
																}
															}
			;

integerExpr:	INTEGER										{
																Trace("Reducing to integerExpr Form INTEGER\n");

																if (!nowIsConstant && !symTabs.isNowGlobal()) 
																{															
																	printTabs();
																	fp << "sipush " << $1.intVal << endl;
																}
															}
			;

realExpr:		REAL										{ Trace("Reducing to realExpr Form REAL\n"); }
			;

boolExpr:		KW_TRUE										{
																Trace("Reducing to boolExpr Form KW_TRUE\n");

																$$.tokenType = T_BOOL;
																$$.boolVal = true;

																if (!nowIsConstant && !symTabs.isNowGlobal()) 
																{
																	printTabs();
																	fp << "iconst_1 " << endl;
																}
															}
			|	KW_FALSE									{
																Trace("Reducing to boolExpr Form KW_FALSE\n");

																$$.tokenType = T_BOOL;
																$$.boolVal = false;

																if (!nowIsConstant && !symTabs.isNowGlobal()) 
																{
																	printTabs();
																	fp << "iconst_0 " << endl;
																}
															}
			|	'!' expression								{
																Trace("Reducing to boolExpr Form '!' expression\n");

																$$.tokenType = T_BOOL;
																$$.boolVal = !$2.boolVal;

																if (!nowIsConstant && !symTabs.isNowGlobal()) 
																{
																	printTabs();
																	fp << "iconst_1" << endl;
																	printTabs();
																	fp << "ixor" << endl;
																}
															}
			|	expression '>' expression					{
																Trace("Reducing to boolExpr Form expression '>' expression\n");

																$$.tokenType = T_BOOL;
																if ($1.notInit)
																	yyerror("'>' left arg is not initial.");
																if ($3.notInit)
																	yyerror("'>' right arg is not initial.");

																if ($1.tokenType == T_INT && $3.tokenType == T_INT)
																	$$.boolVal = $1.intVal > $3.intVal;
																else if ($1.tokenType == T_FLOAT && $3.tokenType == T_FLOAT)
																	$$.boolVal = $1.floatVal > $3.floatVal;
																else if ($1.tokenType == T_STRING && $3.tokenType == T_STRING)
																	$$.boolVal = $1.stringVal > $3.stringVal;
																else
																	yyerror("'>' arg type error.");

																printTabs();
																fp << "isub" << endl;
																printTabs();
																fp << "ifgt " << "L" << nowLabelIndex << endl;
																printTabs();
																fp << "iconst_0" << endl;
																printTabs();
																fp << "goto " << "L" << nowLabelIndex + 1 << endl;
																fp << "L" << nowLabelIndex << ":" << endl;
																printTabs();
																fp << "iconst_1" << endl;
																fp << "L" << nowLabelIndex + 1 << ":" << endl;
																nowLabelIndex += 2;
															}
			|	expression '<' expression					{
																Trace("Reducing to boolExpr Form expression '<' expression\n");

																$$.tokenType = T_BOOL;
																if ($1.notInit)
																	yyerror("'<' left arg is not initial.");
																if ($3.notInit)
																	yyerror("'<' right arg is not initial.");

																if ($1.tokenType == T_INT && $3.tokenType == T_INT)
																	$$.boolVal = $1.intVal < $3.intVal;
																else if ($1.tokenType == T_FLOAT && $3.tokenType == T_FLOAT)
																	$$.boolVal = $1.floatVal < $3.floatVal;
																else if ($1.tokenType == T_STRING && $3.tokenType == T_STRING)
																	$$.boolVal = $1.stringVal < $3.stringVal;
																else
																	yyerror("'<' arg type error.");

																printTabs();
																fp << "isub" << endl;
																printTabs();
																fp << "iflt " << "L" << nowLabelIndex << endl;
																printTabs();
																fp << "iconst_0" << endl;
																printTabs();
																fp << "goto " << "L" << nowLabelIndex + 1 << endl;
																fp << "L" << nowLabelIndex << ":" << endl;
																printTabs();
																fp << "iconst_1" << endl;
																fp << "L" << nowLabelIndex + 1 << ":" << endl;
																nowLabelIndex += 2;
															}
			|	expression OP_AND expression				{
																Trace("Reducing to boolExpr Form boolExpr OP_AND boolExpr\n");

																if (!($1.tokenType == T_BOOL && $3.tokenType == T_BOOL))
																	yyerror("'&&' arg type error.");

																$$.tokenType = T_BOOL;
																$$.boolVal = $1.boolVal && $3.boolVal;
																if (!nowIsConstant && !symTabs.isNowGlobal()) 
																{
																	printTabs();
																	fp << "iand" << endl;
																}
															}
			|	expression OP_OR expression					{
																Trace("Reducing to boolExpr Form boolExpr OP_OR boolExpr\n");

																if (!($1.tokenType == T_BOOL && $3.tokenType == T_BOOL))
																	yyerror("'&&' arg type error.");

																$$.tokenType = T_BOOL;
																$$.boolVal = $1.boolVal || $3.boolVal;

																if (!nowIsConstant && !symTabs.isNowGlobal()) 
																{
																	printTabs();
																	fp << "ior" << endl;
																}
															}
			|	expression OP_EQUAL expression				{
																Trace("Reducing to boolExpr Form expression OP_EQUAL expression\n");

																$$.tokenType = T_BOOL;
																if ($1.notInit)
																	yyerror("'==' left arg is not initial.");
																if ($3.notInit)
																	yyerror("'==' right arg is not initial.");

																if ($1.tokenType == T_INT && $3.tokenType == T_INT)
																	$$.boolVal = $1.intVal == $3.intVal;
																else if ($1.tokenType == T_FLOAT && $3.tokenType == T_FLOAT)
																	$$.boolVal = $1.floatVal == $3.floatVal;
																else if ($1.tokenType == T_STRING && $3.tokenType == T_STRING)
																	$$.boolVal = $1.stringVal == $3.stringVal;
																else if ($1.tokenType == T_BOOL && $3.tokenType == T_BOOL)
																	$$.boolVal = $1.boolVal == $3.boolVal;
																else
																	yyerror("'==' arg type error.");

																printTabs();
																fp << "isub" << endl;
																printTabs();
																fp << "ifeq " << "L" << nowLabelIndex << endl;
																printTabs();
																fp << "iconst_0" << endl;
																printTabs();
																fp << "goto " << "L" << nowLabelIndex + 1 << endl;
																fp << "L" << nowLabelIndex << ":" << endl;
																printTabs();
																fp << "iconst_1" << endl;
																fp << "L" << nowLabelIndex + 1 << ":" << endl;
																nowLabelIndex += 2;
															}
			|	expression OP_NOT_EQUAL expression			{
																Trace("Reducing to boolExpr Form expression OP_NOT_EQUAL expression\n");

																$$.tokenType = T_BOOL;
																if ($1.notInit)
																	yyerror("'!=' left arg is not initial.");
																if ($3.notInit)
																	yyerror("'!=' right arg is not initial.");

																if ($1.tokenType == T_INT && $3.tokenType == T_INT)
																	$$.boolVal = $1.intVal != $3.intVal;
																else if ($1.tokenType == T_FLOAT && $3.tokenType == T_FLOAT)
																	$$.boolVal = $1.floatVal != $3.floatVal;
																else if ($1.tokenType == T_STRING && $3.tokenType == T_STRING)
																	$$.boolVal = $1.stringVal != $3.stringVal;
																else if ($1.tokenType == T_BOOL && $3.tokenType == T_BOOL)
																	$$.boolVal = $1.boolVal != $3.boolVal;
																else
																	yyerror("'!=' arg type error.");

																printTabs();
																fp << "isub" << endl;
																printTabs();
																fp << "ifnq " << "L" << nowLabelIndex << endl;
																printTabs();
																fp << "iconst_0" << endl;
																printTabs();
																fp << "goto " << "L" << nowLabelIndex + 1 << endl;
																fp << "L" << nowLabelIndex << ":" << endl;
																printTabs();
																fp << "iconst_1" << endl;
																fp << "L" << nowLabelIndex + 1 << ":" << endl;
																nowLabelIndex += 2;
															}
			|	expression OP_GREAT_EQUAL expression		{
																Trace("Reducing to boolExpr Form expression OP_GREAT_EQUAL expression\n");

																$$.tokenType = T_BOOL;
																if ($1.notInit)
																	yyerror("'>=' left arg is not initial.");
																if ($3.notInit)
																	yyerror("'>=' right arg is not initial.");

																if ($1.tokenType == T_INT && $3.tokenType == T_INT)
																	$$.boolVal = $1.intVal >= $3.intVal;
																else if ($1.tokenType == T_FLOAT && $3.tokenType == T_FLOAT)
																	$$.boolVal = $1.floatVal >= $3.floatVal;
																else if ($1.tokenType == T_STRING && $3.tokenType == T_STRING)
																	$$.boolVal = $1.stringVal >= $3.stringVal;
																else
																	yyerror("'>=' arg type error.");

																printTabs();
																fp << "isub" << endl;
																printTabs();
																fp << "ifge " << "L" << nowLabelIndex << endl;
																printTabs();
																fp << "iconst_0" << endl;
																printTabs();
																fp << "goto " << "L" << nowLabelIndex + 1 << endl;
																fp << "L" << nowLabelIndex << ":" << endl;
																printTabs();
																fp << "iconst_1" << endl;
																fp << "L" << nowLabelIndex + 1 << ":" << endl;
																nowLabelIndex += 2;
															}
			|	expression OP_LESS_EQUAL expression			{
																Trace("Reducing to boolExpr Form expression OP_LESS_EQUAL expression\n");

																$$.tokenType = T_BOOL;
																if ($1.notInit)
																	yyerror("'<=' left arg is not initial.");
																if ($3.notInit)
																	yyerror("'<=' right arg is not initial.");

																if ($1.tokenType == T_INT && $3.tokenType == T_INT)
																	$$.boolVal = $1.intVal <= $3.intVal;
																else if ($1.tokenType == T_FLOAT && $3.tokenType == T_FLOAT)
																	$$.boolVal = $1.floatVal <= $3.floatVal;
																else if ($1.tokenType == T_STRING && $3.tokenType == T_STRING)
																	$$.boolVal = $1.stringVal <= $3.stringVal;
																else
																	yyerror("'<=' arg type error.");

																printTabs();
																fp << "isub" << endl;
																printTabs();
																fp << "ifle " << "L" << nowLabelIndex << endl;
																printTabs();
																fp << "iconst_0" << endl;
																printTabs();
																fp << "goto " << "L" << nowLabelIndex + 1 << endl;
																fp << "L" << nowLabelIndex << ":" << endl;
																printTabs();
																fp << "iconst_1" << endl;
																fp << "L" << nowLabelIndex + 1 << ":" << endl;
																nowLabelIndex += 2;
															}
			;

stringExpr:		STRING										{
																Trace("Reducing to stringExpr Form STRING\n");

																if (!nowIsConstant && !symTabs.isNowGlobal()) 
																{
																	printTabs();
																	fp << "ldc \"" << $1.stringVal << "\"" << endl;
																}
															}
			;

functionInvoc:	ID '(' parameters ')'		{
												Trace("Reducing to functionInvoc Form ID '(' parameters ')'\n");

												variableEntry ve = symTabs.lookup($1.stringVal);
												if (ve.type == T_404)
													yyerror("function ID not found");

												$$.tokenType = ve.type;

												printTabs();
												fp << "invokestatic ";
												if (ve.type == T_INT)
													fp << "int ";
												else if (ve.type == T_BOOL)
													fp << "bool ";

												fp << outputfileName << "." << ve.name << "(";

												for (int i = 0; i < ve.argSize; i++)
												{
													if (ve.argType[i] == T_INT)
														fp << "int";
													else if (ve.argType[i] == T_BOOL)
														fp << "bool";

													if (i != ve.argSize - 1)
														fp << ", ";
												}
												fp << ")" << endl;
											}
			;

parameters:		expression ',' parameters	{ Trace("Reducing to parameters Form expression ',' parameters\n"); }
			|	expression					{ Trace("Reducing to parameters Form expression\n"); }
			|	%empty						{ Trace("Reducing to parameters Form empty\n"); }
			;

block:			'{' 						{
												symTabs.push_table("this");
											}
				scopeContent '}'			{
												Trace("Reducing to block Form '{' scopeContent '}'\n");

												symTabs.pop_table();
											}
			;

ifStament:		KW_IF '(' conBoolExpr ')' 				{
														printTabs();
														fp << "ifeq " << "L" << nowLabelIndex << endl;
														topElseLabel.push_back(nowLabelIndex);

														nowLabelIndex++;
													}
				block elseStament					{
														Trace("Reducing to ifStament Form KW_IF '(' boolExpr ')' block elseStament\n");

														fp << "L" << topElseLabel.back() << ":" << endl;

														topElseLabel.pop_back();

														printTabs();
														fp << "nop" <<endl;
													}
			;

elseStament:	KW_ELSE 							{
														printTabs();
														fp << "goto " << "L" << nowLabelIndex << endl;
														fp << "L" << topElseLabel.back() << ":" << endl;
														topElseLabel.pop_back();
														topElseLabel.push_back(nowLabelIndex);

														nowLabelIndex++;

														printTabs();
														fp << "nop" <<endl;
													}
				block 								{ Trace("Reducing to elseStament Form KW_ELSE block\n"); }
			|	%empty								{ Trace("Reducing to elseStament Form empty\n"); }
			;

loop:			KW_WHILE			{
										fp << "L" << nowLabelIndex << ":" << endl;
										$1.beginLabel = nowLabelIndex;
										nowLabelIndex++;
									}
				'(' conBoolExpr ')' {
										printTabs();
										fp << "ifeq " << "L" << nowLabelIndex << endl;
										$1.exitLabel = nowLabelIndex;
										nowLabelIndex++;
									}

				block				{
										Trace("Reducing to loop Form KW_WHILE '(' boolExpr ')' block\n");

										printTabs();
										fp << "goto " << "L" << $1.beginLabel << endl;
										fp << "L" << $1.exitLabel << ":" << endl;
										printTabs();
										fp << "nop" <<endl;
									}
			;

conBoolExpr:	boolExpr			{ Trace("Reducing to conBoolExpr Form boolExpr"); }
			|	ID					{
										Trace("Reducing to conBoolExpr Form ID"); 
										variableEntry ve = symTabs.lookup($1.stringVal);
										if (ve.type == T_404)
											yyerror("ID not found");
										else if (ve.type == T_NONE)
											yyerror("ID not init");
										else if (ve.isArr)
											yyerror("Array no give index");
										else if (ve.isFn)
											yyerror("Function no parameters");
										else if (ve.type != T_INT && ve.type != T_BOOL)
											yyerror("Not bool expression");

										if (ve.isConst)
										{
											printTabs();
											if (ve.type == T_INT)
												fp << "sipush " << ve.data.intVal << endl;
											else if (ve.type == T_BOOL)
												fp << "iconst_" << ve.data.boolVal << endl;
										}
										else
										{
											if (ve.isGlobal)
											{
												printTabs();
												if (ve.type == T_INT)
													fp << "getstatic int " << outputfileName << "." << ve.name << endl;
												else if (ve.type == T_BOOL)
													fp << "getstatic int " << outputfileName << "." << ve.name << endl;
											}
											else
											{
												printTabs();
												if (ve.type == T_INT)
													fp << "iload " << ve.stackIndex << endl;
												else if (ve.type == T_BOOL)
													fp << "iload " << ve.stackIndex << endl;
											}
										}
									}
			;

%%

int yyerror(const char *s)
{
	fprintf(stderr, "ERROR: %s at line number:%d\n", s, yylineno);
	exit(-1);
	return 0;
}

void printTabs()
{
	for (int i = 0; i < nowTabs; i++)
		fp << "\t";
}

int main(int argc, char *argv[])
{
    // Open srcfile.
	if (argc != 2 && argc !=3)
	{
        fprintf(stderr, "Usage: rust.exe <filename>\n");
		fprintf(stderr, "Usage: rust.exe <filename> <outputfileName>\n");
        exit(-1);
    }

	yyin = fopen(argv[1], "r");

	if (argc == 3)
		outputfileName = argv[2];

	// Write jasm.
	fp.open(outputfileName + ".jasm", ios::out);
    if (!fp) {
		fprintf(stderr, "ERROR: Fail to open %s\n", outputfileName.c_str());
		exit(-1);
	}

	fp << "class " << outputfileName << endl << "{" << endl;
	nowTabs++;

	yyparse();

	fp << "}";
    fp.close();

	return 0;
}