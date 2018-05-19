%{
#include <iostream>
#include <vector>
#include <stdlib.h>
#include <stdio.h>
#include "symbol.h"

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
%token KW_ELSE
%token KW_ENUM
%token KW_EXTERN
%token KW_FALSE
%token KW_FLOAT
%token KW_FOR
%token KW_FN
%token KW_IF
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
%token KW_WHILE

%start program

%left OP_OR OP_AND '!'
%left '>' '<' OP_GREAT_EQUAL OP_EQUAL OP_LESS_EQUAL OP_NOT_EQUAL
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

%%
program:		declarations functionDecs	{ Trace("Reducing to start\n"); }
			|	functionDecs				{ Trace("Reducing to start\n"); }
			;

declarations:	declaration					{ Trace("Reducing to declarations\n"); }
			|	declaration declarations	{ Trace("Reducing to declarations\n"); }			
			;

declaration:	varDec					{ Trace("Reducing to declaration\n"); }
			|	constDec				{ Trace("Reducing to declaration\n"); }
			|	arrDec					{ Trace("Reducing to declaration\n"); }
			;			

type:			KW_STR					{ Trace("Reducing to type\n"); }
			|	KW_INT					{ Trace("Reducing to type\n"); }
			|	KW_BOOL					{ Trace("Reducing to type\n"); }
			|	KW_FLOAT				{ Trace("Reducing to type\n"); }
			;

varDec:			KW_LET KW_MUT ID ':' type ';'					{ Trace("Reducing to variableDeclaration\n"); }
			|	KW_LET KW_MUT ID '=' expression	';'				{ Trace("Reducing to variableDeclaration\n"); }
			|	KW_LET KW_MUT ID ':' type '=' expression ';'	{ Trace("Reducing to variableDeclaration\n"); }
			|	KW_LET KW_MUT ID ';'							{ Trace("Reducing to variableDeclaration\n"); }
			;

constDec:		KW_LET ID ':' type ';'					{ Trace("Reducing to constantDeclaration\n"); }
			|	KW_LET ID '=' expression ';'			{ Trace("Reducing to constantDeclaration\n"); }
			|	KW_LET ID ':' type '=' expression ';'	{ Trace("Reducing to constantDeclaration\n"); }
			;

arrDec:			KW_LET KW_MUT ID '[' type ',' integerExpr ']' ';'
			;

functionDecs:	functionDec								{ Trace("Reducing to functionDeclarations\n"); }
			|	functionDec functionDecs				{ Trace("Reducing to functionDeclarations\n"); }
			;

functionDec:	KW_FN ID '('  ')' scope								{ Trace("Reducing to functionDeclaration\n"); }
			|	KW_FN ID '(' formalArgs ')' scope					{ Trace("Reducing to functionDeclaration\n"); }
			|	KW_FN ID '('  ')' '-' '>' type	scope				{ Trace("Reducing to functionDeclaration\n"); }
			|	KW_FN ID '(' formalArgs ')' '-' '>' type scope		{ Trace("Reducing to functionDeclaration\n"); }
			;

formalArgs:		ID ':' type					{ Trace("Reducing to formalArgs\n"); }
			|	ID ':' type ',' formalArgs	{ Trace("Reducing to formalArgs\n"); }
			;

scope:			'{' '}'						{ Trace("Reducing to scope\n"); }
			|	'{' scopeContent '}'
			;

scopeContent:	declarations scopeContent	{ Trace("Reducing to scopeContent\n"); }
			|	statements scopeContent		{ Trace("Reducing to scopeContent\n"); }
			|	declarations				{ Trace("Reducing to scopeContent\n"); }
			|	statements					{ Trace("Reducing to scopeContent\n"); }
			;

statements:		statement statements		{ Trace("Reducing to statements\n"); }
			|	statement					{ Trace("Reducing to statements\n"); }
			;

statement:		ID '=' expression ';'						{ Trace("Reducing to statement\n"); }
			|	ID '[' integerExpr']' '=' expression ';'	{ Trace("Reducing to statement\n"); }
			|	KW_PRINT expression	';'						{ Trace("Reducing to statement\n"); }
			|	KW_PRINTLN expression ';'					{ Trace("Reducing to statement\n"); }
			|	KW_RETURN expression ';'					{ Trace("Reducing to statement\n"); }
			|	KW_RETURN ';'								{ Trace("Reducing to statement\n"); }
			|	block										{ Trace("Reducing to statement\n"); }
			|	conditional									{ Trace("Reducing to statement\n"); }
			|	loop										{ Trace("Reducing to statement\n"); }
			|	functionInvoc								{ Trace("Reducing to statement\n"); }
			;

expression:		'-' expression %prec UMINUS					{ Trace("Reducing to expression\n"); }
			|	expression '+' expression					{ Trace("Reducing to expression\n"); }
			|	expression '-' expression					{ Trace("Reducing to expression\n"); }
			|	expression '*' expression					{ Trace("Reducing to expression\n"); }
			|	expression '/' expression					{ Trace("Reducing to expression\n"); }
			|	expression '%' expression					{ Trace("Reducing to expression\n"); }
			|	'(' expression ')'							{ Trace("Reducing to expression\n"); }
			|	integerExpr									{ Trace("Reducing to expression\n"); }
			|	realExpr									{ Trace("Reducing to expression\n"); }
			|	boolExpr									{ Trace("Reducing to expression\n"); }
			|	stringExpr									{ Trace("Reducing to expression\n"); }
			|	functionInvoc								{ Trace("Reducing to expression\n"); }
			|	ID											{ Trace("Reducing to expression\n"); }
			|	ID '[' integerExpr ']'						{ Trace("Reducing to expression\n"); }
			;	

integerExpr:	INTEGER		{ Trace("Reducing to integerExpr\n"); }
			;

realExpr:		REAL		{ Trace("Reducing to realExpr\n"); }
			;

boolExpr:		KW_TRUE										{ Trace("Reducing to boolExpr\n"); }
			|	KW_FALSE									{ Trace("Reducing to boolExpr\n"); }
			|	'!' expression								{ Trace("Reducing to boolExpr\n"); }
			|	expression '>' expression
			|	expression '<' expression					{ Trace("Reducing to boolExpr\n"); }
			|	expression OP_AND expression				{ Trace("Reducing to boolExpr\n"); }
			|	expression OP_OR expression					{ Trace("Reducing to boolExpr\n"); }
			|	expression OP_EQUAL expression				{ Trace("Reducing to boolExpr\n"); }
			|	expression OP_NOT_EQUAL expression			{ Trace("Reducing to boolExpr\n"); }
			|	expression OP_GREAT_EQUAL expression		{ Trace("Reducing to boolExpr\n"); }
			|	expression OP_LESS_EQUAL expression			{ Trace("Reducing to boolExpr\n"); }
			;

stringExpr:		STRING						{ Trace("Reducing to stringExpr\n"); }
			;

functionInvoc:	ID '(' parameters ')'		{ Trace("Reducing to functionInvoc\n"); }

parameters:		expression ',' parameters	{ Trace("Reducing to integerExpr\n"); }
			|	expression					{ Trace("Reducing to parameters\n"); }
			;

block:		'{' statements '}'				{ Trace("Reducing to block\n"); }

conditional:	KW_IF '(' boolExpr ')' block				{ Trace("Reducing to conditional\n"); }
			|	KW_IF '(' boolExpr ')' block KW_ELSE block 	{ Trace("Reducing to conditional\n"); }

loop:			KW_WHILE '(' boolExpr ')' block				{ Trace("Reducing to loop\n"); }

%%



int yyerror(const char *s)
{
	fprintf(stderr, "%s\n", s);
	return 0;
}

int main(void)
{
	// For test cpp function

	// create();

	yyparse();

	// dump();

	return 0;
}
