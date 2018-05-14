%{
#include <stdio.h>
#define LIST     strcat(buf,yytext)
#define token(t) {LIST; printf("<'%s'>\n", t);}
#define tokenInteger(t,i) {LIST; printf("<%s:%d>\n", t,i);}
#define tokenString(t,s) {LIST; printf("<%s:%s>\n", t, s);}
#define keyword(k) {LIST; printf("<%s>\n", k);}

#define MAX_LINE_LENG 1024
#define MAX_SYMBOL 1024

int linenum = 1;
char buf[MAX_LINE_LENG];

int mutiCommentTimes = 0;

char stringTemp[MAX_LINE_LENG];

int symbolCount = 0;
char **symbolTable;

int create();
int lookup(char* s);
int insert(char* s);
int dump();

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
                tokenInteger("integer", atoi(yytext));
                }

{real}          {
                tokenString("real", yytext);
                }

\"              {
                LIST;    
                BEGIN(IN_STRING);
                }

<IN_STRING>\"   {
                tokenString("string",stringTemp);
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

","     {token(yytext);}
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
"++"    {token(yytext);}
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

"bool"          {keyword("BOOL");}
"break"         {keyword("BREAK");}
"char"          {keyword("CHAR");}
"continue"      {keyword("CONTINUE");}
"do"            {keyword("DO");}
"else"          {keyword("ELSE");}
"enum"          {keyword("ENUM");}
"extern"        {keyword("EXTERN");}
"false"         {keyword("FALSE");}
"float"         {keyword("FLOAT");}
"for"           {keyword("FOR");}
"fn"            {keyword("FN");}
"if"            {keyword("IF");}
"in"            {keyword("IN");}
"int"           {keyword("INT");}
"let"           {keyword("LET");}
"loop"          {keyword("LOOP");}
"match"         {keyword("MATCH");}
"mut"           {keyword("MUT");}
"print"         {keyword("PRINT");}
"println"       {keyword("PRINTLN");}
"pub"           {keyword("PUB");}
"return"        {keyword("RETURN");}
"self"          {keyword("SELF");}
"static"        {keyword("STATIC");}
"str"           {keyword("STR");}
"struct"        {keyword("STRUCT");}
"true"          {keyword("TRUE");}
"use"           {keyword("USE");}
"where"         {keyword("WHERE");}
"while"         {keyword("WHILE");}

{ID}            {
                tokenString("id",yytext);
                insert(yytext);
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

[ \t]*  {LIST;}

\n|\r\n {
        LIST;
        printf("%d: %s", linenum++, buf);
        buf[0] = '\0';
        }

.       {
        LIST;
        printf("%d:%s\n", linenum, buf);
        printf("bad character:'%s'\n", yytext);
        exit(-1);
        }

%%

int main()
{
        create();
        
        // main() need containing yylex() to do lexical analyze.
        yylex();

        dump();

        fflush(yyout);
        exit(0);
}

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

int create()
{
        symbolTable = malloc(MAX_SYMBOL*sizeof(char*));
}

int lookup(char* s)
{
        for (int i = 0; i < symbolCount; i++)
        {
                if (strcmp(symbolTable[i], s) == 0)
                        return i;
        }
        return -1;
}

int insert(char* s)
{
        if (lookup(s) == -1)
        {
                symbolTable[symbolCount] = malloc(yyleng * sizeof(char));
                strcpy(symbolTable[symbolCount], s);
                symbolCount++;                
        }
        return symbolCount - 1;
}

int dump()
{
        printf("\nSymbol Table:\n");
        
        for (int i = 0; i < symbolCount; i++)
        {               
                printf("%s\n", symbolTable[i]);
                free(symbolTable[symbolCount]);
        }

        free(symbolTable);

        return symbolCount;
}
