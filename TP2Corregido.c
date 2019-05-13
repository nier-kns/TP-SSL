#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <windows.h>

#define MAX_LENGTH 100
#define VACIO -1
#define EXP_1 1
#define EXP_2 2
#define TER_1 3
#define TER_2 4
#define FAC 5
#define NUM 6

typedef struct nodoPila
{
	int accion;
	struct nodoPila* sig;
}nodoPila;

void apilar(nodoPila**, int);
void desapilar(nodoPila**, int*);
void mostrarPila(nodoPila*);
char* codigos(int);
void comenzar(void);
void siguiente(nodoPila **, int, char);
int cambiarEstado(int, char);
void recorrerCadena(char*);
int esDigito(char);
int esOperacion(char);

int main(void)
{
	comenzar();
	
	return 0;
}

void comenzar(void)
{
	char cadenaLeido[MAX_LENGTH];
	
	printf("Ingrese cadena: ");
	gets(cadenaLeido);
	
	while(strcmp(cadenaLeido, "exit"))
	{
		recorrerCadena(cadenaLeido);
		printf("Ingrese cadena: ");
		gets(cadenaLeido);
	}
}

void recorrerCadena(char* cadena)
{
	char *chp = NULL;
	int cima = 0, accionATomar = 0, estado = 0;
	nodoPila* pila = NULL;

	apilar(&pila, VACIO);

	chp = cadena;
	do
	{
		mostrarPila(pila);
		desapilar(&pila, &cima);
		estado = cambiarEstado(cima, *chp);
		siguiente(&pila, cima, *chp);
		printf("'%c' ", *chp);

		if (estado == 1)
		{
			estado = 0;
			chp++;
		}
	}while (estado != 2 && pila->accion != VACIO);
	
	if (estado == 2 || pila->accion != VACIO)
		printf("\nSyntax Error\n");
	else
		printf("\nValido\n");
}

void siguiente(nodoPila **pila, int codigo, char ch)
{
	switch(codigo)
	{
		case VACIO:
			apilar(pila, VACIO);
			apilar(pila, EXP_1);
			break;
		case EXP_1:
			apilar(pila, EXP_2);
			apilar(pila, TER_1);
			break;
		case EXP_2:
			if (ch == '+')
			{
				apilar(pila, EXP_2);
				apilar(pila, TER_1);
			}
			break;
		case TER_1:
			apilar(pila, TER_2);
			apilar(pila, FAC);
			
			break;
		case TER_2:
			if (ch == '*')
			{
				apilar(pila, TER_2);
				apilar(pila, FAC);
			}
			break;
		case FAC:
			if (ch == '(')
			{
				apilar(pila, EXP_1);
				apilar(pila, ')');
				
			}
			else
				apilar(pila, NUM);
			break;
		default:
			;
	}
}

int cambiarEstado(int codigo, char ch)
{
	int estado = 0;
	
	switch(codigo)
	{
		case VACIO:
			if(ch == '*' || ch == '+')
				estado = 2;
			else if (!esDigito(ch))
				estado = 2;
			break;
		case EXP_1:
			if(ch == '*' || ch =='+')
				estado = 2;
			break;
		case EXP_2:
			if(ch == '+')
				estado = 1;
			else if (esDigito(ch))
				estado = 2;
			break;
		case TER_1:
			if(ch == '*' || ch =='+')
				estado = 2;
			break;
		case TER_2:
			if(ch == '*')
				estado = 1;
			else if (esDigito(ch))
				estado = 2;
			break;
		case FAC:
			if(ch == '*' || ch =='+')
				estado = 2;
			break;		
		case NUM:
			if(esDigito(ch))
				estado = 1;
			break;
		case ')':
			estado = 1;
			break;
		default:
			;
	}
	
	return estado;
}

void apilar(nodoPila **p, int n)
{
	nodoPila *aux = (nodoPila*) malloc(sizeof(nodoPila));
	aux->accion = n;
	aux->sig = *p;
	*p = aux;
	
	return;
}

void desapilar(nodoPila **p, int *np)
{
	nodoPila *aux = *p;
	
	if (p != NULL)
	{
		*np = aux->accion;
		*p = aux->sig;
		free(aux);
	}

	return;
}

void mostrarPila(nodoPila* p)
{
	nodoPila *aux = p;
	
	while(aux != NULL)
	{
		printf("%s ", codigos(aux->accion));
		aux = aux->sig;
		//Sleep(500);
	}
	printf("\n");
}

char* codigos(int n)
{
	switch (n)
	{
		case VACIO:
			return "$";
		case EXP_1:
			return "E1";
		case EXP_2:
			return "E2";
		case TER_1:
			return "T1";
		case TER_2:
			return "T2";
		case FAC:
			return "F1";
		case NUM:
			return "N";
		case '(':
			return "(";
		case ')':
			return ")";
		default:
			return "Default";
	}
}

int esDigito(char ch)
{
	if(ch >= '0' && ch <= '9')
		return 1;
	else
		return 0;
}

int esOperacion(char ch)
{
	if(ch=='+')
		return 1;
	else if (ch=='*')
		return 2;
	else
		return 0;
}
