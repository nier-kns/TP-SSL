%{

/* Se necesita esto para la llamada a atof() , atoi m�s abajo */

#include <math.h>
#include <stdio.h>
int acum = 0;

%}

CEDECIMAL 	[1-9][0-9]*
CEOCTAL		0[0-7]*
CEHEXA		0[xX][A-Fa-f0-9]+
CREAL	        [0-9]*"."[0-9]+([eE]([\+\-]?)[0-9]+)?
ID       	[a-zA-Z_][a-zA-Z0-9_]*
PRESERVADA	while|do|if|else|for|int|char|return|case|switch

%%

{CREAL}       {printf("La cadena %s representa una constante real\n", yytext);}
{CEDECIMAL}   {acum = acum + atoi(yytext); printf("El valor acumulado es %d\n", acum);}
{CEOCTAL}     {printf("La cadena %s representa una constante entera octal\n", yytext);}
{CEHEXA}      {printf("La cadena %s representa una constante entera hexadecimal\n", yytext);}
{PRESERVADA}  {printf("La cadena %s representa una palabra reservada\n", yytext);}
{ID}          {printf("La cadena %s representa un identificador\n", yytext);}
[ \t\n]+          /* se come los espacios en blanco */

%%

int main(){
    yyout = fopen("salida.txt","w");
    yyin = fopen("entrada.txt","r");
    yylex();
    return 0;
    }
