%{
#include "TP4Bison.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <ctype.h>
#define VOID 0
#define INT 1
#define FLT 2
#define CH 3
#define STR 4

int yywrap(void);
int dataTypeToInt(char*);
%}

CMTSIMPLE \/\/[^\n]*
CMTCOMP   "/*"(.|\n)*"*/"
PRSTIPO   typedef|enum|struct|union|const
SIGN      signed|unsigned
DATATYPE  char|double|float|int|long|short|void
PRIF      if
PRELSE    else
PRCASE    case
PRDEFAULT   default
PRSWITCH    switch 
PRDO do
PRFOR for
PRWHILE while
PRCLSVAR  auto|register|static|extern
PRBREAK break
PRCONTINUE  continue   
PRGOTO  goto
PRRETURN  return
PROP      sizeof
ID        [_a-zA-Z][_a-zA-Z0-9]*
LITCADENA \"([^\"]|\\\")*\"
CTECAR    '(.|'\\t'|'\\n'|'\\'|'\\0')?'
CTEDEC    [1-9][0-9]*
CTEOCT    0[0-7]*
CTEHEX    0[xX][0-9a-fA-F]+
CTEREAL   [0-9]*"."[0-9]+([eE]([\+\-]?)[0-9]+)?
OPSUN     [\&\!\*]|\+{2}
LOGICOR   "||"
LOGICAND  "&&"
LOGICEQ   "=="
LOGICNOTEQ "!="
ASIGNOP   ["+=""-="]
GREATEQ   ">="
LESSEQ    "<="
OPINC     "++"|"--" 
IGNORAR   [ \t\n]+

%%
")"         {return ')';}
"("         {return '(';}
"{"         {return '{';}
"}"         {return '}';}
";"         {return ';';}
"["         {return '[';}
"]"         {return ']';}
"?"         {return '?';}
"="         {return '=';}
":"         {return ':';}
">"         {return '>';}
"<"         {return '<';}
"+"         {return '+';}
"-"         {return '-';}
"*"         {return '*';}
"/"         {return '/';}
"%"         {return '%';}
"&"         {return '&';}
"!"         {return '!';}
","         {return ',';}
{DATATYPE}  {yylval.s.type = dataTypeToInt(yytext); return DATATYPE;}
{PRIF}      {return PRIF;}
{PRELSE}    {return PRELSE;}
{PRSWITCH}  {return PRSWITCH;}
{PRWHILE}   {return PRWHILE;}
{PRDO}      {return PRDO;}
{PRFOR}     {return PRFOR;}
{PRRETURN}  {return PRRETURN;}
{PROP}      {printf("rp found\n");return PROP;}
{ID}        {yylval.s.isReserved = 0; return ID;}
{CTEHEX}    {yylval.n.type = INT; return CTEHEX;}
{CTECAR}    {yylval.n.type = CH; return CTECAR;}
{CTEDEC}    {yylval.n.type = INT; return CTEDEC;}
{CTEOCT}    {yylval.n.type = INT; return CTEOCT;}
{CTEREAL}   {yylval.n.type = FLT; return CTEREAL;}
{ASIGNOP}   {return ASIGNOP;}
{LOGICOR}   {return LOGICOR;}
{LOGICAND}  {return LOGICAND;}
{LOGICEQ}   {return LOGICEQ;}
{LOGICNOTEQ} {return LOGICNOTEQ;}
{GREATEQ}   {return GREATEQ;}
{LESSEQ}    {return LESSEQ;}
{OPINC}     {return OPINC;}
{LITCADENA} {return LITCADENA;}
"\n"        {return '\n';}
%%

int yywrap(void)
{
    return 1;
}

int dataTypeToInt(char* dataString)
{
    if(strcmp(dataString, "int") || strcmp(dataString, "short") || strcmp(dataString, "int"))
        return INT;
    else if(strcmp(dataString, "double") || strcmp(dataString, "float"))
        return FLT;
    else if(strcmp(dataString, "char"))
        return CH;
    else
        return VOID;
}