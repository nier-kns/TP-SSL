%{
    #include <math.h>
    #include <stdio.h>
    #include <ctype.h>
    #include <stdlib.h>
    #define VOID 0
    #define INT 1
    #define FLT 2
    #define CH 3
    #define STR 4
    #define YYERROR_VERBOSE
    extern FILE* yyin;
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
    void yyerror(char*);

    int err = 0, esLvalue = 0, tipo;
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
} 
//Terminales de asignacion-----------
%token <n> CTEDEC CTEOCT CTEHEX CTEREAL CTECAR
%token <s> DATATYPE ID
//---------Terminales de asignacion
//Terminales de expresion---------------
%token <n> ASIGNOP LOGICOR LOGICAND LOGICEQ LOGICNOTEQ GREATEQ LESSEQ OPINC LITCADENA PROP
//----------Terminales de expresion
//No terminales de asignacion
%type <s> listaDeclaracion var varSimple varComp inicial puntero constantes
//-----------No terminales de asignacion
//Terminales de sentencias-----------
%token <s> PRIF PRELSE PRSWITCH PRWHILE PRRETURN PRDO PRFOR
//-----------Terminales de sentencias
%start input

%%

input: /*vacio*/
      | input line
;
line: '\n'
      | codigo '\n'
      | line '\n'
;

codigo: definicion
       | declaracion
;

definicion: DATATYPE puntero ID '(' parametros ')' sentencia
;
parametros: DATATYPE ID
           | parametros ',' DATATYPE ID
           | /*vacio*/
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
            | expAditiva '+' expMultiplicativa
            | expAditiva '-' expMultiplicativa
;
expMultiplicativa: expUnaria
                  | expMultiplicativa '*' expUnaria
                  | expMultiplicativa '/' expUnaria
                  | expMultiplicativa '%' expUnaria
;
expUnaria: expPostfijo
          | OPINC expUnaria
          | expUnaria OPINC
          | operUnario expUnaria
          | PROP '(' DATATYPE ')'
          | PROP '(' ID ')'
          | /*vacio*/
;
operUnario: '&' | '*' | '-' | '!'
;
expPostfijo: expPrimaria
            | expPostfijo '[' expresion ']'
            | expPostfijo '(' listaArgumentos ')'
;
listaArgumentos: expAsignacion
                | listaPrimaria
                | listaArgumentos ',' expAsignacion
                | /*vacio*/
;
listaPrimaria: expPrimaria
              | listaPrimaria expPrimaria
              | /*vacio*/
;
expPrimaria: ID {esLvalue = 1;}
            | LITCADENA
            | constantes
            | '(' expresion ')'
;
constantes: CTECAR {$<s.type>$ = $<n.type>1;}
            | CTEDEC {$<s.type>$ = $<n.type>1;}
            | CTEOCT {$<s.type>$ = $<n.type>1;}
            | CTEHEX {$<s.type>$ = $<n.type>1;}
            | CTEREAL {$<s.type>$ = $<n.type>1;}
;

declaracion: prototipo
             | DATATYPE {tipo = $<s.type>1} puntero listaDeclaracion ';' {tipo = -1;}
;
prototipo: DATATYPE puntero ID '(' listaTipos ')' ';'
;
puntero: '*' puntero
        | /*vacio*/
;
listaDeclaracion:   var 
                  | listaDeclaracion ',' var
;
listaTipos:  DATATYPE
           | listaTipos ',' DATATYPE
           | /*vacio*/
;
var: varSimple
    | varComp
;
varSimple:  ID inicial
;
varComp: ID '[' expresion ']'
        | varComp '[' expresion ']'
;
inicial:  '=' constantes {if(tipo != $<s.type>2) {err = 1; printf("Tipo del constante no corresponde al tipo declarado\n");}}
        | /*vacio*/
;

sentencia: sentCompuesta
          | sentExpresion 
          | sentSeleccion
          | sentIteracion
          | sentSalto
;

sentCompuesta: '{' listaDeclaraciones listaSentencias '}'
;
listaDeclaraciones: declaracion
                   | listaDeclaraciones declaracion
                   | /*vacio*/
;

listaSentencias: sentencia
                | listaSentencias sentencia
                | /*vacio*/
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
              | PRFOR '(' expresion ';' expresion ';' expresion ')' sentencia
;

sentSalto: PRRETURN sentExpresion
;
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

void yyerror(char* err)
{
    printf("%s\n", err);
}

main()
{
    //yyin = fopen("tpi.c", "r+");
    yyparse();
    if(err != 0)
        printf("Error\n");
}
