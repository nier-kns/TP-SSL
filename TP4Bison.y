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

    void yyerror(char*);
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
%type <s> listaDeclaracion var varSimple varComp inicial puntero
//-----------No terminales de asignacion
%start input

%%

input: /*vacio*/
      | input line
;
line: '\n'
      | codigo '\n'
;
codigo: declaracion | expresion
;

expresion: expAsignacion
;
expAsignacion: expCondicional
            | expUnaria operAsignacion expAsignacion
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
;
operUnario: '&' | '*' | '-' | '!'
;
expPostfijo: expPrimaria
            | expPostfijo '[' expresion ']'
            | expPostfijo '(' listaArgumentos ')'
;
listaArgumentos: expAsignacion
                | listaArgumentos ',' expAsignacion
                | /*vacio*/
;
expPrimaria: ID
            | LITCADENA
            | constantes
            | '(' expresion ')'
;
constantes: CTECAR
            | CTEDEC
            | CTEOCT
            | CTEHEX
            | CTEREAL
;

declaracion: DATATYPE puntero listaDeclaracion ';'
;
puntero: '*' puntero
        | /*vacio*/
;
listaDeclaracion:   var
                  | listaDeclaracion ',' var
;
var: varSimple
    | varComp
;
varSimple:  ID inicial
;
varComp: ID '[' expresion ']'
        | varComp '[' expresion ']'
;
inicial:  '=' expCondicional
        | /*vacio*/
;
%%

void yyerror(char* err)
{
    printf("%s\n", err);
}

main()
{
    yyparse();
}
