%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#define DEC 10
#define OCT 8
#define HEX 16
#define REAL 4

typedef struct _Registro
{
    char* palabra;
    int cant, len;
}Registro;

typedef struct NodoLista
{
    Registro info;
    struct NodoLista* sig;
}NodoLista;

void agregarALista(NodoLista**, char*);
NodoLista* buscarNodo(NodoLista*, char*);
void mostrarPalYCant(NodoLista*);
void mostrarPalabras(NodoLista*);
void mostrarLiterales(NodoLista*);
void mostrarCTEs(NodoLista*, int);
void mostrarReales(NodoLista*);

int acum = 0;

NodoLista* listaID = NULL;
NodoLista* listaPR = NULL;
NodoLista* listaLiteralc = NULL;
NodoLista* listaCTECAR = NULL;
NodoLista* listaCTEDEC = NULL;
NodoLista* listaCTEOCT = NULL;
NodoLista* listaCTEHEX = NULL;
NodoLista* listaCTEREAL = NULL;
NodoLista* listaCmt = NULL;
NodoLista* listaPunt = NULL;
NodoLista* listaOps = NULL;

%}

CMTSIMPLE \/\/[^\n]*
CMTCOMP   "/*"(.|\n)*"*/"
PUNT      \[|\]|\{|\}|\,|\;|\(|\)
PRSTIPO   typedef|enum|struct|union|const|signed|unsigned|char|double|float|int|long|short|void
PRSSELEC  case|default|else|if|switch
PRITER    do|for|while
PRCLSVAR  auto|register|static|extern
PRSALTO   break|continue|goto|return
PROP      sizeof
ID        [_a-zA-Z][_a-zA-Z0-9]*
LITCADENA \"([^\"]|\\\")*\"
CTECAR    '([ -&\\\(-~]|'\\t'|'\\n'|'\\'|'\\0')?'
CTEDEC    [1-9][0-9]*
CTEOCT    0[0-7]*
CTEHEX    0[xX][0-9a-fA-F]+
CTEREAL   [0-9]*"."[0-9]+([eE]([\+\-]?)[0-9]+)?
OPS       [\&\*\-\!"++"\*\+\"<"">""<=""<=""==""&&""||"\="+="]
IGNORAR   [ \t\n]+

%%
{PRSTIPO}   {agregarALista(&listaPR, yytext);}
{PRSSELEC}  {agregarALista(&listaPR, yytext);}
{PRITER}    {agregarALista(&listaPR, yytext);}
{PRCLSVAR}  {agregarALista(&listaPR, yytext);}
{PRSALTO}   {agregarALista(&listaPR, yytext);}
{PROP}      {agregarALista(&listaPR, yytext);}
{CTEHEX}    {agregarALista(&listaCTEHEX, yytext);}
({CTEDEC}|{CTEOCT}){ID} {agregarALista(&listaID, yytext);}
{ID}        {agregarALista(&listaID, yytext);}
{LITCADENA} {agregarALista(&listaLiteralc, yytext);}
{CTECAR}    {agregarALista(&listaCTECAR, yytext);}
{CTEDEC}    {agregarALista(&listaCTEDEC, yytext); acum += atoi(yytext);}
{CTEOCT}    {agregarALista(&listaCTEOCT, yytext);}
{CTEREAL}   {agregarALista(&listaCTEREAL, yytext);}
{CMTSIMPLE}|{CMTCOMP}      {agregarALista(&listaCmt, yytext);}
{PUNT}      {agregarALista(&listaPunt, yytext);}
{OPS}       {agregarALista(&listaOps, yytext);}
{IGNORAR}   ; 

%%

void agregarALista(NodoLista** lista, char* p)
{
    NodoLista *nodo, *aux1 = *lista, *aux2 = NULL;

    nodo = buscarNodo(*lista, p);

    if(nodo == NULL)
    {
        nodo = (NodoLista*) malloc(sizeof(NodoLista)+ strlen(p) + 1);
        nodo->info.palabra = (char*) malloc(strlen(p) + 1);
        strcpy(nodo->info.palabra, p);
        nodo->info.cant = 1;
        nodo->info.len = strlen(p);
        
        while(aux1 != NULL && strcmp(aux1->info.palabra, p) < 0)
        {
            aux2 = aux1;
            aux1 = aux1->sig;
        }
        if(aux1 == *lista)
            *lista = nodo;
        else
            aux2->sig = nodo;

        nodo->sig = aux1;
    }
    else
        nodo->info.cant++;
}


NodoLista* buscarNodo(NodoLista* lista, char* p)
{
    NodoLista* aux = lista;

    while(aux != NULL)
    {
        if(strcmp(aux->info.palabra, p) == 0)
            return aux;
        aux = aux->sig;
    }

    return NULL;
}

void mostrarPalYCant(NodoLista* lista)
{
    NodoLista* aux = lista;
    
    while(aux != NULL)
    {
        if(isdigit(aux->info.palabra[0]))
            printf("Error identificador no valido: %s\n", aux->info.palabra);
        else
            printf("Palabra: %s\nCantidad de apariciones: %d\n", aux->info.palabra, aux->info.cant);
        aux = aux->sig;
    }
}

void mostrarPalabras(NodoLista* lista)
{
    NodoLista* aux = lista;

    while(aux != NULL)
    {
        printf("Palabra: %s\n", aux->info.palabra);
        aux = aux->sig;
    }
}

void mostrarLiterales(NodoLista* lista)
{
    NodoLista* aux = lista;

    while(aux != NULL)
    {
        printf("Palabra: %s\nLongitud de la palabra: %d\n", aux->info.palabra, aux->info.len);
        aux = aux->sig;
    }
}

void mostrarCTEs(NodoLista* lista, int tipo)
{
    NodoLista* aux = lista;
    char *c;

    if(tipo % 8 == 0)
    {
        while(aux != NULL)
        {
            printf("Palabra: %s\nValor decimal: %ld\n", aux->info.palabra, strtoul(aux->info.palabra, &c, tipo));
            aux = aux->sig;
        }
    }
    else
    {
        while(aux != NULL)
        {
            printf("Palabra: %s\n", aux->info.palabra);
            aux = aux->sig;
        }
        printf("Valor acumulado: %d\n", acum);
    }
}

void mostrarReales(NodoLista* lista)
{
    NodoLista* aux = lista;
    int* n;

    while(aux != NULL)
    {

        printf("Palabra: %s\nParte entera: %d\nMantisa(normalizada): %.6lf", aux->info.palabra, atoi(aux->info.palabra), frexp(atof(aux->info.palabra), n));
        aux = aux->sig;
    }
}

void mostrarComentarios(NodoLista* lista)
{
    NodoLista* aux = lista;

    while(aux != NULL)
    {
        if(aux->info.palabra[1] == '*')
            printf("Palabra: %s\n", aux->info.palabra);
        else
            printf("Palabra: %s\n", aux->info.palabra);
        aux = aux->sig;
    }

}

int main(void)
{
    yyin = fopen("testIn.c", "r");
    yyout = fopen("testOut.txt", "w");
    yylex();
    printf("Identificadores\n\n");
    mostrarPalYCant(listaID);
    printf("\nPalabras Reservadas\n\n");
    mostrarPalabras(listaPR);
    printf("\nLiterales cadena\n\n");
    mostrarLiterales(listaLiteralc);
    printf("\nConstantes Caracteres\n\n");
    mostrarPalabras(listaCTECAR);
    printf("\nConstantes Decimales\n\n");
    mostrarCTEs(listaCTEDEC, DEC);
    printf("\nConstantes Octales\n\n");
    mostrarCTEs(listaCTEOCT, OCT);
    printf("\nConstantes Hexadecimales\n\n");
    mostrarCTEs(listaCTEHEX, HEX);
    printf("\nConstantes Reales\n\n");
    mostrarReales(listaCTEREAL);
    printf("\nPuntuaciones\n\n");
    mostrarPalYCant(listaPunt);
    printf("\nOperaciones\n\n");
    mostrarPalYCant(listaOps);
    printf("\nComentarios\n\n");
    mostrarComentarios(listaCmt);

    return 0;
}