%{
    #include <math.h>
    #include <stdio.h>
    #include <ctype.h>
    #include <string.h>
    #include <stdlib.h>
    #define VOID 0
    #define INT 1
    #define FLT 2
    #define CH 3
    #define YYERROR_VERBOSE
    #define YYDEBUG 1
    extern FILE* yyin;

    typedef struct _Registro
    {
        char* palabra;
        char* tipo;
        char* tipos[50];
    }Registro;

    typedef struct NodoLista
    {
        Registro info;
        struct NodoLista* sig;
    }NodoLista;

    void agregarAListaVar(NodoLista**, char*, int);
    void agregarAListaFunc(NodoLista**, char*, int, int[]);
    NodoLista* buscarNodo(NodoLista*, char*);
    char* intToDataType(int);
    void mostrarListaVar(NodoLista*);
    void mostrarListaFunc(NodoLista*);
    void yyerror(char*);

    NodoLista *listaVar = NULL, *listaFunc = NULL, *aux;
    int err = 0, esLvalue = 0, tipo = -1, i = 0, l = 0, funciones[50][50] = {0};

%}

%union
{
    struct
    {
        int type;
        float value;
    }n;
    struct
    {
        char string[50];
        char isReserved;
        int type;
    }s;
    struct
    {
        int types[50];
    }f;
}
//Terminales de asignacion-----------
%token <n> CTEDEC CTEOCT CTEHEX CTEREAL CTECAR
%token <s> DATATYPE ID
//---------Terminales de asignacion
//Terminales de expresion---------------
%token <n> ASIGNOP LOGICOR LOGICAND LOGICEQ LOGICNOTEQ GREATEQ LESSEQ OPINC LITCADENA PROP
//----------Terminales de expresion
//No terminales de asignacion
%type <s> listaDeclaracion var inicial puntero constantes
//-----------No terminales de asignacion
//Terminales de sentencias-----------
%token <s> PRIF PRELSE PRSWITCH PRWHILE PRRETURN PRDO PRFOR
//-----------Terminales de sentencias
%type <s> expAditiva expMultiplicativa expUnaria expPostfijo listaArgumentos expPrimaria listaPrimaria
%type <f> parametros

%start input

%%

input: /*vacio*/
      | input line
;
line: '\n'
      | sentencia '\n'
      | sentencia
      | error
;
expresion: expAsignacion
          | /*vacio*/
;
expAsignacion: expCondicional
            | expUnaria operAsignacion expAsignacion {if(!esLvalue) printf("Error, la asignacion necesita un lvalue\n");}
;
operAsignacion: ASIGNOP
               | '='
;
expCondicional: expOr
                | expOr '?' expresion ':' expCondicional
;
expOr: expAnd
      | expOr LOGICOR expAnd
;
expAnd: expIgualdad
        | expAnd LOGICAND expIgualdad
;
expIgualdad: expRelacional
            | expIgualdad LOGICEQ expRelacional
            | expIgualdad LOGICNOTEQ expRelacional
;
expRelacional: expAditiva
             | expRelacional GREATEQ expAditiva
             | expRelacional '>' expAditiva
             | expRelacional LESSEQ expAditiva
             | expRelacional '<' expAditiva
;
expAditiva: expMultiplicativa
            | expAditiva '+' expMultiplicativa {if ($<s.type>1!=$<s.type>3) printf("No se corresponden los tipos de datos en la suma");}
            | expAditiva '-' expMultiplicativa {if ($<s.type>1!=$<s.type>3) printf("No se corresponden los tipos de datos en la resta");}
;
expMultiplicativa: expUnaria
                  | expMultiplicativa '*' expUnaria {if ($<s.type>1!=$<s.type>3) printf("No se corresponden los tipos de datos en la multiplicacion");}
                  | expMultiplicativa '/' expUnaria {if ($<s.type>1!=$<s.type>3) printf("No se corresponden los tipos de datos en la division");}
                  | expMultiplicativa '%' expUnaria {if ($<s.type>1!=$<s.type>3) printf("No se corresponden los tipos de datos en el cociente");}
;
expUnaria: expPostfijo {$<s.type>$ = $<s.type>1;}
          | OPINC expUnaria
          | expUnaria OPINC
          | operUnario expUnaria
          | PROP '(' DATATYPE ')'
          | PROP '(' ID ')'
          | /*vacio*/
;
operUnario: '&' | '*' | '-' | '!'
;
expPostfijo: expPrimaria {$<s.type>$ = $<s.type>1;}
            | expPostfijo '[' expresion ']'
            | expPostfijo '(' listaArgumentos ')' {$<s.type>$ = $<s.type>1;}
;
listaArgumentos: expAsignacion
                | listaPrimaria {$<s.type>$ = $<s.type>1;}
                | listaArgumentos ',' expAsignacion
                | /*vacio*/
;
listaPrimaria: expPrimaria {$<s.type>$ = $<s.type>1;}
              | listaPrimaria expPrimaria {$<s.type>$ = $<s.type>2;}
              | /*vacio*/
;
expPrimaria: ID {esLvalue = 1;}
            | LITCADENA
            | constantes {$<s.type>$ = $<s.type>1;}
            | '(' expresion ')'
;
constantes: CTECAR {$<s.type>$ = $<n.type>1;}
            | CTEDEC {$<s.type>$ = $<n.type>1;}
            | CTEOCT {$<s.type>$ = $<n.type>1;}
            | CTEHEX {$<s.type>$ = $<n.type>1;}
            | CTEREAL {$<s.type>$ = $<n.type>1;}
;
sentencia: sentCompuesta
          | sentExpresion 
          | sentSeleccion
          | sentIteracion
          | sentSalto
          | declaracionAlfa
;
sentCompuesta: '{' listaSentencias '}'
;
listaSentencias: /*vacio*/
			| listaSentencias '\n'
			| listaSentencias sentencia '\n'
;
sentExpresion: expresion ';'
              | /*vacio*/
;
sentSeleccion: PRIF '(' expresion ')' sentencia
              | PRIF '(' expresion ')' sentencia PRELSE sentencia
              | PRSWITCH '(' expresion ')' sentencia
;
sentIteracion: PRWHILE '(' expresion ')' sentencia
              | PRDO sentencia PRWHILE '(' expresion ')' ';'
              | PRFOR '(' listaDeclaracion ';' expresion ';' expresion ')' sentencia
;
sentSalto: PRRETURN sentExpresion
;

declaracionAlfa: DATATYPE {tipo = $<s.type>1;} puntero declaracion
;

declaracion: listaDeclaracion ';'
            | funcion
;

funcion: ID '(' parametros ')' protOdef {aux = buscarNodo(listaFunc, $<s.string>1); if(aux!=NULL) printf("Error semantico: funcion doblemente declarada\n"); else agregarAListaFunc(&listaFunc, $<s.string>1, $<s.type>1, funciones[i]); i++; l = 0;}
;
protOdef: sentencia
         | ';'
;
parametros: DATATYPE var {funciones[i][l] = $<s.type>1; l++;}
           | parametros ',' DATATYPE var {funciones[i][l] = $<s.type>3; l++;}
           | /*vacio*/ {funciones[i][l] = 0;}
;
puntero: '*' puntero
        | /*vacio*/
;
listaDeclaracion:   var 
                  | listaDeclaracion ',' var
;
var: ID arreglo inicial {aux = buscarNodo(listaVar, $<s.string>1); if(aux != NULL) printf("Error: Variable doblemente declarada\n"); else agregarAListaVar(&listaVar, $<s.string>1, $<s.type>1);}
;
arreglo: '[' expresion ']'
        | arreglo '[' expresion ']'
        | /*vacio*/
;
inicial:  '=' constantes {if(tipo != $<s.type>2) {err = 1; printf("Tipo del constante no corresponde al tipo declarado\n"); printf("%d", tipo);}}
        | /*vacio*/
;
%%

void agregarAListaVar(NodoLista** lista, char* p, int t)
{
    NodoLista *nodo, *aux1 = *lista, *aux2 = NULL;

    nodo = buscarNodo(*lista, p);

    if(nodo == NULL)
    {
        nodo = (NodoLista*) malloc(sizeof(NodoLista)+ strlen(p) + 1);
        nodo->info.palabra = (char*) malloc(strlen(p) + 1);
        nodo->info.tipo = intToDataType(t);
        strcpy(nodo->info.palabra, p);
        
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
}

void agregarAListaFunc(NodoLista** lista, char* p, int t, int ts[])
{
    NodoLista *nodo, *aux1 = *lista, *aux2 = NULL;
    int j = 0;

    nodo = (NodoLista*) malloc(sizeof(NodoLista)+ strlen(p) + 1);
    nodo->info.palabra = (char*) malloc(strlen(p) + 1);
    nodo->info.tipo = intToDataType(t);

    strcpy(nodo->info.palabra, p);
    
    if(aux1 == *lista)
        *lista = nodo;
    else
        aux2->sig = nodo;

    nodo->sig = aux1;
}

void mostrarListaVar(NodoLista* listaVar)
{
    NodoLista* aux = listaVar;

    printf("Lista de variables\n\n");

    while(aux!=NULL)
    {
        printf("Nombre: %s\nTipo: %s\n\n", aux->info.palabra, aux->info.tipo);
        aux = aux->sig;
    }
}

void mostrarListaFunc(NodoLista* listaFunc)
{
    NodoLista* aux = listaFunc;
    int k = 0, m = 0;
    printf("Lista de funciones\n\n");

    while(k < i)
    {
        printf("Nombre: %s\nDevuelve: %s\n", aux->info.palabra, aux->info.tipo);
        while(funciones[k][m] != 0)
        {
            printf("Tipo parametro nro.%d: %s\n", m+1, intToDataType(funciones[k][m]));
            m++;
        }
        k++;
        m = 0;
        aux = aux->sig;
    }
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

char* intToDataType(int n)
{
    switch(n)
    {
        case INT:
            return "int";
        case FLT:
            return "float/double";
        case CH:
            return "char";
        case VOID:
            return "void";
    }
}

void inicializar(int a[])
{

}

void yyerror(char* err)
{
    printf("%s\n", err);
}

main()
{   

    yyin = fopen("tpi.c", "r+");
    do
    {
        yyparse();
    }while (!feof(yyin));
    
    
    mostrarListaVar(listaVar);
    printf("\n");
    mostrarListaFunc(listaFunc);

}
