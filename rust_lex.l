%{
#include <stdlib.h>
#include <stdio.h>
#include "y.tab.h"

#define LIST    strcat(buf, yytext)
#define keyword(k)  { LIST;  }
#define token(t)    { LIST;  }
#define tokenType(type, val) { LIST; return type; }

#define MAX_LINE_LENG 1024

extern "C"{
    int yywrap();
    int yylex();
}

int linenum = 1;
char buf[MAX_LINE_LENG];

int mutiCommentTimes = 0;

char stringTemp[MAX_LINE_LENG];

%}

alphabet        [a-zA-z]
alphabets       [a-zA-z]+

dig             [0-9]
digs            [0-9]+

integer         {digs}
plain_real      [+-]?{digs}"."{digs}
expreal         [+-]?{digs}"."{digs}[Ee][+-]?{digs}
real            {plain_real}|{expreal}|[+-]?{digs}[Ee][+-]?{digs}

ID              {alphabet}({alphabet}|{dig})*

%x IN_STRING
%x IN_COMMENT
%x IN_LINECOMMENT

%%

{integer}       {
                    tokenType(INTEGER, atoi(yytext));                  
                }

{real}          {
                    tokenType(REAL, yytext);
                }

\"              {
                    LIST;    
                    BEGIN(IN_STRING);
                }

<IN_STRING>\"   {
                    tokenType(STRING, stringTemp);
                    stringTemp[0] = '\0';
                    BEGIN(INITIAL);
                } 

<IN_STRING>\n   {
                    LIST;
                    printf("%d: %s", linenum++, buf);
                    buf[0] = '\0';
                    strcat(stringTemp,"\n");
                }

<IN_STRING>\"\" {
                    LIST;
                    strcat(stringTemp,"\"");             
                }

<IN_STRING>.    {
                    LIST;
                    strcat(stringTemp,yytext);               
                }

","     {token(yytext); return ',';}
":"     {token(yytext);}
";"     {token(yytext);}
"("     {token(yytext);}
")"     {token(yytext);}
"["     {token(yytext);}
"]"     {token(yytext);}
"{"     {token(yytext);}
"}"     {token(yytext);}
"+"     {token(yytext);}
"-"     {token(yytext);}
"*"     {token(yytext);}
"/"     {token(yytext);}
"++"    {token(yytext); return PLUS_PLUS;}
"--"    {token(yytext);}
"%"     {token(yytext);}
"<"     {token(yytext);}
">"     {token(yytext);}
"<="    {token(yytext);}
">="    {token(yytext);}
"=="    {token(yytext);}
"!="    {token(yytext);}
"&&"    {token(yytext);}
"||"    {token(yytext);}
"!"     {token(yytext);}
"="     {token(yytext);}
"+="    {token(yytext);}
"-="    {token(yytext);}
"*="    {token(yytext);}
"/="    {token(yytext);}

"bool"          {keyword(BOOL);}
"break"         {keyword(BREAK);}
"char"          {keyword(CHAR);}
"continue"      {keyword(CONTINUE);}
"do"            {keyword(DO);}
"else"          {keyword(ELSE);}
"enum"          {keyword(ENUM);}
"extern"        {keyword(EXTERN);}
"false"         {keyword(FALSE);}
"float"         {keyword(FLOAT);}
"for"           {keyword(FOR);}
"fn"            {keyword(FN);}
"if"            {keyword(IF);}
"in"            {keyword(IN);}
"int"           {keyword(INT);}
"let"           {keyword(LET);}
"loop"          {keyword(LOOP);}
"match"         {keyword(MATCH);}
"mut"           {keyword(MUT);}
"print"         {keyword(PRINT);}
"println"       {keyword(PRINTLN);}
"pub"           {keyword(PUB);}
"return"        {keyword(RETURN);}
"self"          {keyword(SELF);}
"static"        {keyword(STATIC);}
"str"           {keyword(STR);}
"struct"        {keyword(STRUCT);}
"true"          {keyword(TRUE);}
"use"           {keyword(USE);}
"where"         {keyword(WHERE);}
"while"         {keyword(WHILE);}

{ID}            {
                    tokenType(ID, yytext);  
                }

"/*"    {
            LIST;
            mutiCommentTimes++;
            BEGIN(IN_COMMENT);
        }

<IN_COMMENT>"*/"        {
                            LIST;
                            mutiCommentTimes--;
                            if (mutiCommentTimes == 0)
                                BEGIN(INITIAL);
                        }

<IN_COMMENT>"/*"        {
                            LIST;
                            mutiCommentTimes++;
                        }                       

<IN_COMMENT>\n          {
                            LIST;
                            printf("%d: %s", linenum++, buf);
                            buf[0] = '\0';
                        }

<IN_COMMENT>.           {LIST;}

"//"    {
            LIST;
            BEGIN(IN_LINECOMMENT);
        }

<IN_LINECOMMENT>\n      {
                            LIST;
                            printf("%d: %s", linenum++, buf);
                            buf[0] = '\0';
                            BEGIN(INITIAL);
                        }

<IN_LINECOMMENT>.       {LIST;}

[ \t]*      {LIST;}

\n|\r\n     {
                LIST;
                printf("%d: %s", linenum++, buf);
                buf[0] = '\0';
            }

.           {
                LIST;
                printf("%d:%s\n", linenum, buf);
                printf("bad character:'%s'\n", yytext);
                exit(-1);
            }

%%

// called by lexical analyzer if end of the input file.
int yywrap()
{
    printf("%d:%s\n", linenum, buf);
    if(stringTemp[0] != '\0')
    {       
        printf("unterminated double quote string");
        exit(-1);
    }
    return 1;
}
