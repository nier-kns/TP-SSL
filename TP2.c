#include <stdio.h>
#include <stdlib.h>
#include <windows.h>

#define MAX_LENGTH 100
#define E1 1
#define E2 2
#define T1 3
#define T2 4
#define F1 5
#define T1_E2 32
#define F1_T2 54
#define DN 4
#define D 6
#define N 7
#define EPSILON 8
#define ERR 9
#define KEEP 10

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
void recorrerCadena(char *);
void siguienteAccion(nodoPila**, char, int, int *);

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

	apilar(&pila, -1);

	chp = cadena;
	do
	{
		mostrarPila(pila);
		desapilar(&pila, &cima);
		siguienteAccion(&pila, *chp, cima, &estado);
		printf("'%c' ", *chp);

		if (estado == 1)
		{
			estado = 0;
			chp++;
		}
	}while (pila->accion != -1 && estado != 2 && *chp != '\0');
	
	if (estado == 2 || pila->accion != -1)
		printf("\nSyntax Error\n");
	else
		printf("\nValido\n");
}

void siguienteAccion(nodoPila **p, char ch, int accion, int* estado)
{
	int a;
	switch(accion)
	{
		case -1:
			if (ch >= 0x30 && ch <= 0x39)
			{
				apilar(p, -1);
				apilar(p, E1);
			}
			else if (ch == '+')
			{
				apilar(p, -1);
				apilar(p, E1);
			}
			else
			{
				apilar(p, -1);
				*estado = 2;
			}
			break;
		case E1:
			apilar(p, E2);
			apilar(p, T1);
			break;
		case E2:
			if (ch == '+')
			{
				apilar(p, E2);
				apilar(p, T1);
				*estado = 1;
			}
			//else
			//	desapilar(p, &a);
			break;
		case T1:
			apilar(p, T2);
			apilar(p, F1);
			break;
		case T2:
			if (ch == '*')
			{
				apilar(p, T2);
				apilar(p, F1);
				*estado = 1;
			}
			//else
			//	desapilar(p, &a);
			break;
		case F1:
			apilar(p, N);
			break;
		case N:
			if (ch >= 0x30 && ch <= 0x39)
			{
				*estado = 1;
				//desapilar(p, &a);
			}
			else if (ch == '+')
				*estado = 1;
			else
				*estado = 2;
	}
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
		case -1:
			return "$";
		case E1:
			return "E1";
		case E2:
			return "E2";
		case T1:
			return "T1";
		case T2:
			return "T2";
		case F1:
			return "F1";
		case N:
			return "N";
		default:
			return "Default";
	}
}
